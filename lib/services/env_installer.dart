import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/spacy_size.dart';
import 'package:chat/services/platform_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallerService {
  bool pythonInstalled; // python
  bool backendConnected; // frontend is connected to the backend Endpoint
  bool backendInstalled; // the topos-cli
  APIConfig apiConfig;
  InstallerService({
    required this.apiConfig,
    required this.navigatorKey,
    this.backendConnected = false,
    this.backendInstalled = false,
    this.pythonInstalled = true,
  });

  GlobalKey<NavigatorState> navigatorKey;

  final ValueNotifier<List<String>> outputNotifier =
      ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> isConnecting = ValueNotifier(false);

  FToast fToast = FToast();

  List<String> endingStatements = [
    "Installation complete!",
  ];
  void _addOutput(String data) {
    if (data.trim().isNotEmpty) {
      outputNotifier.value = List.from(outputNotifier.value)..add(data.trim());
      outputNotifier.notifyListeners();
    }
  }

  Future<void> runCommand(String executable, List<String> arguments) async {
    var process = await Process.start(executable, arguments);
    process.stdout.transform(utf8.decoder).listen((data) {
      debugPrint(data);
      _addOutput(data);
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      debugPrint(data);
      _addOutput(data);
    });

    var exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ProcessException(executable, arguments,
          'Command failed with exit code $exitCode', exitCode);
    }
    debugPrint('$executable ${arguments.join(' ')} executed successfully.');
  }

  Future<void> runCommandWithPassword(String executable, List<String> arguments,
      {Map<String, String>? environment}) async {
    var process =
        await Process.start(executable, arguments, environment: environment);

    process.stdout.transform(utf8.decoder).listen((data) {
      debugPrint(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      debugPrint(data);
    });

    var exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ProcessException(executable, arguments,
          'Command failed with exit code $exitCode', exitCode);
    }
    print('$executable ${arguments.join(' ')} executed successfully.');
  }

  // Future<bool> checkIfCommandExists(String command) async {
  //   try {
  //     var result = await Process.run('which', [command]);
  //     debugPrint("Checking command: $command");
  //     debugPrint("stdout: ${result.stdout.toString()}");
  //     debugPrint("stderr: ${result.stderr.toString()}");
  //     return result.stdout
  //         .toString()
  //         .trim()
  //         .isNotEmpty; // Ensure trimming any extra spaces
  //   } catch (e) {
  //     debugPrint("Error checking command: $e");
  //     return false;
  //   }
  // }

  Future<bool> checkIfCommandExists(String command) async {
    try {
      // Create a temporary directory and script file
      final tempDir = await getTemporaryDirectory();
      final scriptFile = File('${tempDir.path}/check_command.sh');

      // Write the check_command.sh script to the file
      await scriptFile.writeAsString('''
    #!/bin/bash
    WORK_DIR=\$1
    cd \$WORK_DIR

    CHAT_APP_COMMAND=$command

    # Check if the command exists
    if [ -x "\$CHAT_APP_COMMAND" ]; then
        echo "exists"
    else
        echo "not found"
    fi
    ''');

      // Make the script executable
      await runCommand('chmod', ['+x', scriptFile.path]);

      // Run the script with the temporary directory as an argument
      var result =
          await Process.run('/bin/sh', [scriptFile.path, tempDir.path]);
      debugPrint("stdout: ${result.stdout.toString()}");
      // debugPrint("stderr: ${result.stderr.toString()}");
      debugPrint(
          "command_exists :: ${result.stdout.toString().trim() == 'exists'}");
      return result.stdout.toString().trim() == 'exists';
    } catch (e) {
      debugPrint("Error checking command: $e");
      return false;
    }
  }

  Future<bool> killServer(String httpAddress) async {
    try {
      final response = await http.post(Uri.parse('$httpAddress/shutdown'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on http.ClientException catch (e) {
      return false;
    } on SocketException catch (e) {
      return false;
    } on FormatException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> getToposPath() async {
    try {
      final pathFile = File('${Platform.environment['HOME']}/topos_path.txt');
      print("Topos pathfile :: ${pathFile.toString()}");
      if (await pathFile.exists()) {
        print("path_string :: ${await pathFile.readAsString()}");
        return await pathFile.readAsString();
      } else {
        throw Exception("Topos path file not found");
      }
    } catch (e) {
      debugPrint("Error reading topos path: $e");
      return 'topos'; // Fallback to default command
    }
  }

  Future<Map<String, dynamic>> setSpacyModel(
      {SpacyModel spacySize = SpacyModel.small}) async {
    debugPrint("\t[ turning topos on ]");
    isConnecting.value = true;
    isConnecting.notifyListeners();
    String spacyModelSelection = getSpacyModelString(spacySize);
    var toposPath = await getToposPath();

    // Create a temporary directory and script file
    final tempDir = await getTemporaryDirectory();
    final scriptFile = File('${tempDir.path}/run_topos.sh');

    // Write the run_topos.sh script to the file
    await scriptFile.writeAsString('''
  #!/bin/bash
  WORK_DIR=\$1
  cd \$WORK_DIR

  # Get the string of topos path from ~/topos_path.txt
  # TOPOS_PATH=\$(cat ~/topos_path.txt)
  
  TOPOS_PATH=$toposPath

  # Run the topos command
  \$TOPOS_PATH set --spacy $spacyModelSelection
  ''');

    // Make the script executable
    await runCommand('chmod', ['+x', scriptFile.path]);

    // Run the script with the temporary directory as an argument
    var process =
        await Process.start('/bin/sh', [scriptFile.path, tempDir.path]);

    // var process = await Process.start(toposPath, ['run']);
    var urlCompleter = Completer<String>();
    var isRunning = false;

    // Function to handle data and errors from the process
    void handleOutput(String data) {
      _addOutput(data);
      if (data.contains('Uvicorn running on')) {
        var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
        if (match != null) {
          urlCompleter.complete(match.group(0));
          isRunning = true;
        }
      }
    }

    // Listening to stdout
    process.stdout.transform(utf8.decoder).listen(handleOutput);

    // Listening to stderr
    process.stderr.transform(utf8.decoder).listen(handleOutput);

    var url = await urlCompleter.future.timeout(const Duration(seconds: 20),
        onTimeout: () {
      throw TimeoutException('Failed to start Topos within the timeout period');
    });

    if (!isRunning) {
      throw Exception('Failed to start Topos');
    }
    isConnecting.value = false;
    isConnecting.notifyListeners();
    return {'isRunning': isRunning, 'url': url};
  }

  Future<Map<String, dynamic>> turnToposOn(String httpAddress) async {
    debugPrint("\t[ turning topos on ]");
    isConnecting.value = true;
    isConnecting.notifyListeners();
    var toposPath = await getToposPath();

    // Create a temporary directory and script file
    final tempDir = await getTemporaryDirectory();
    final scriptFile = File('${tempDir.path}/run_topos.sh');

    // Write the run_topos.sh script to the file
    await scriptFile.writeAsString('''
  #!/bin/bash
  WORK_DIR=\$1
  cd \$WORK_DIR

  # Get the string of topos path from ~/topos_path.txt
  # TOPOS_PATH=\$(cat ~/topos_path.txt)
  
  TOPOS_PATH=$toposPath

  # Run the topos command
  \$TOPOS_PATH run
  ''');

    // Make the script executable
    await runCommand('chmod', ['+x', scriptFile.path]);

    // Run the script with the temporary directory as an argument
    var process =
        await Process.start('/bin/sh', [scriptFile.path, tempDir.path]);

    // var process = await Process.start(toposPath, ['run']);
    var urlCompleter = Completer<String>();
    var isRunning = false;

    // Function to handle data and errors from the process
    void handleOutput(String data) {
      _addOutput(data);
      if (data.contains('Uvicorn running on')) {
        var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
        if (match != null) {
          urlCompleter.complete(match.group(0));
          isRunning = true;
        }
      }
      if (data.contains("address already in use")) {
        killServer(httpAddress).then((value) => () async {
              process = await Process.start(
                  '/bin/sh', [scriptFile.path, tempDir.path]);
            });
      }
    }

    // Listening to stdout
    process.stdout.transform(utf8.decoder).listen(handleOutput);

    // Listening to stderr
    process.stderr.transform(utf8.decoder).listen(handleOutput);

    var url = await urlCompleter.future.timeout(const Duration(seconds: 20),
        onTimeout: () {
      throw TimeoutException('Failed to start Topos within the timeout period');
    });

    if (!isRunning) {
      throw Exception('Failed to start Topos');
    }
    isConnecting.value = false;
    isConnecting.notifyListeners();
    return {'isRunning': isRunning, 'url': url};
  }

  Future<bool> uninstallTopos() async {
    debugPrint("\t[ uninstalling topos ]");
    isConnecting.value = true;
    isConnecting.notifyListeners();

    // Create a temporary directory and script file
    final tempDir = await getTemporaryDirectory();
    final scriptFile = File('${tempDir.path}/uninstall_topos.sh');

    // Write the uninstall_topos.sh script to the file
    await scriptFile.writeAsString('''
  #!/bin/bash
  WORK_DIR=\$1
  cd \$WORK_DIR

  # Uninstall topos using pip3
  pip3 uninstall -y topos
  ''');

    // Make the script executable
    await runCommand('chmod', ['+x', scriptFile.path]);

    // Run the script with the temporary directory as an argument
    var process =
        await Process.start('/bin/sh', [scriptFile.path, tempDir.path]);

    var completer = Completer<bool>();
    bool success = false;

    // Function to handle data and errors from the process
    void handleOutput(String data) {
      _addOutput(data);
      if (data.contains('Successfully uninstalled')) {
        success = true;
      }
    }

    // Listening to stdout
    process.stdout.transform(utf8.decoder).listen(handleOutput);

    // Listening to stderr
    process.stderr.transform(utf8.decoder).listen(handleOutput);

    await process.exitCode;
    isConnecting.value = false;
    isConnecting.notifyListeners();
    completer.complete(success);

    return completer.future;
  }

  Future<bool> stopToposService(String httpAddress) async {
    try {
      bool killResult = await killServer(httpAddress);
      return killResult;
    } catch (e) {
      print('Failed to stop Topos service: $e');
      return false;
    }
  }

  Future<void> runInstallScript(SpacyModel model) async {
    try {
      String scriptAssetPath;
      String scriptContent;

      if (Platform.isWindows) {
        scriptAssetPath = 'assets/install_scripts/install_windows.txt';
      } else if (Platform.isLinux || Platform.isMacOS) {
        scriptAssetPath = 'assets/install_scripts/install.txt';
      } else if (await IsIosAppOnMac().isiOSAppOnMac()) {
        scriptAssetPath = 'assets/install_scripts/install.txt';
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      // Load the script content from assets
      scriptContent = await rootBundle.loadString(scriptAssetPath);

      // replace the set spacy model in the script with the one selected by user
      String spacyModel = getSimpleSpacyModelString(model);

      // Replace the spacy model in the script content
      scriptContent = scriptContent.replaceFirst(
        RegExp(r'topos set --spacy \w+'),
        'topos set --spacy $spacyModel',
      );
      // Get a temporary directory to write the script file
      final tempDir = await getTemporaryDirectory();
      final scriptFile = File(
          '${tempDir.path}/${Platform.isWindows ? 'install_windows.bat' : 'install.sh'}');

      // Write the script content to the file
      await scriptFile.writeAsString(scriptContent);

      if (!Platform.isWindows) {
        await runCommand('chmod', ['+x', scriptFile.path]);
      }

      // Run the script with the temporary directory as an argument
      await (Platform.isWindows
          ? runCommand('cmd.exe', ['/c', scriptFile.path, tempDir.path])
          : runCommand(
              '/bin/sh', ['-c', '${scriptFile.path} ${tempDir.path}']));
    } catch (e) {
      print('Error running script: $e');
    }
  }

  Future<String> _getLatestCommitHash() async {
    const String githubApiUrl =
        'https://api.github.com/repos/{owner}/{repo}/git/refs/heads/{branch}';
    const String owner = 'jonnyjohnson1';
    const String repo = 'topos-cli';
    const String branch = 'main';
    final String url = githubApiUrl
        .replaceAll('{owner}', owner)
        .replaceAll('{repo}', repo)
        .replaceAll('{branch}', branch);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load latest commit hash');
    }

    final commitData = jsonDecode(response.body);
    return commitData['sha'];
  }

  Future<String?> _readLocalCommitHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_commit_hash');
  }

  Future<void> _writeLocalCommitHash(String commitHash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_commit_hash', commitHash);
  }

  Future<void> checkForUpdates() async {
    final latestCommitHash = await _getLatestCommitHash();
    final localCommitHash = await _readLocalCommitHash();

    if (localCommitHash == null) {
      print('No local commit hash found. Saving the latest commit hash.');
      await _writeLocalCommitHash(latestCommitHash);
      return;
    }

    if (latestCommitHash != localCommitHash) {
      print('Update available!');
      print('Latest commit hash: $latestCommitHash');
      print('Local commit hash: $localCommitHash');
    } else {
      print('No update available.');
    }

    await _writeLocalCommitHash(latestCommitHash);
  }

  Future<void> initEnvironment() async {
    print("Checking backend connection...");
    backendConnected = await checkBackendConnected();
    print("Backend connected :: $backendConnected");
    if (backendConnected) {
      backendInstalled = true;
    } else {
      // await uninstallTopos();
      print("Checking backend installation...");
      backendInstalled = await checkToposCLIInstalled();
      if (backendInstalled) {
        backendConnected = await checkBackendConnected();
        print("Backend connected :: $backendConnected");
      }
    }
    if (backendConnected) {
      // perform other checks if the backend is now installed
    }
  }

  Future<bool> checkBackendConnected() async {
    try {
      final response =
          await http.get(Uri.parse('${apiConfig.getDefault()}/health'));
      return response.statusCode == 200;
    } catch (e) {
      print("Error checking backend connection: $e");
      return false;
    }
  }

  Future<bool> checkToposCLIInstalled({bool autoTurnOn = true}) async {
    if (await isDesktopPlatform(includeIosAppOnMac: true)) {
      debugPrint("\t[ running on desktop ]");
      bool toposIsInstalled = await checkIfCommandExists(await getToposPath());
      if (toposIsInstalled) {
        if (!autoTurnOn) return true;
        try {
          var result = await turnToposOn(apiConfig.getDefault());
          print('Topos is running at ${result['url']}');
          return result['isRunning'];
        } catch (e) {
          print('Failed to run Topos: $e');
          return false;
        }
      } else {
        print('Topos is not installed.');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> printEnvironment() async {
    print("Backend installed: $backendInstalled");
    print("Backend connected: $backendConnected");
    print("Python installed: $pythonInstalled");
    print("Backend fully installed: ${isBackendFullyInstalled()}");
  }

  bool isBackendFullyInstalled() {
    return backendInstalled && pythonInstalled;
  }
}
