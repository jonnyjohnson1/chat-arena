import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/models/display_configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
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

  FToast fToast = FToast();

  bool _isDesktopPlatform() {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  List<String> endingStatements = [
    "Installation complete!",
    "Rust is already installed.",
    """INFO:     127.0.0.1:49448 - "GET /openapi.json HTTP/1.1" 200 OK"""
  ];
  void _addOutput(String data) {
    outputNotifier.value = List.from(outputNotifier.value)..add(data);
    outputNotifier.notifyListeners();
    if (endingStatements.contains(data.trim())) {
      Future.delayed(const Duration(seconds: 2), () {
        outputNotifier.value.add(" ");
        outputNotifier.notifyListeners();
      });
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
    print('$executable ${arguments.join(' ')} executed successfully.');
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

  Future<bool> checkIfCommandExists(String command) async {
    try {
      var result = await Process.run('which', [command]);
      return result.stdout.toString().isNotEmpty;
    } catch (e) {
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

  Future<Map<String, dynamic>> turnToposOn(String httpAddress) async {
    var process = await Process.start('topos', ['run']);
    var urlCompleter = Completer<String>();
    var isRunning = false;
    process.stdout.transform(utf8.decoder).listen((data) async {
      _addOutput(data);
      if (data.contains('Uvicorn running on')) {
        var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
        if (match != null) {
          urlCompleter.complete(match.group(0));
          isRunning = true;
        }
      }
      if (data.contains("address already in use")) {
        await killServer(httpAddress);
        await runCommand('topos', ['run']);
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) async {
      _addOutput(data);
      if (data.contains('Uvicorn running on')) {
        var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
        if (match != null) {
          urlCompleter.complete(match.group(0));
          isRunning = true;
        }
      }
      if (data.contains("address already in use")) {
        await killServer(httpAddress);
        await runCommand('topos', ['run']);
      }
    });

    var url = await urlCompleter.future.timeout(const Duration(seconds: 8),
        onTimeout: () {
      throw TimeoutException('Failed to start Topos within the timeout period');
    });

    if (!isRunning) {
      throw Exception('Failed to start Topos');
    }

    return {'isRunning': isRunning, 'url': url};
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

  Future<void> runInstallScript() async {
    try {
      String scriptPath;
      if (Platform.isWindows) {
        scriptPath = '${Directory.current.path}\\scripts\\install_windows.bat';
      } else if (Platform.isLinux || Platform.isMacOS) {
        scriptPath = '${Directory.current.path}/scripts/install.sh';
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      if (!Platform.isWindows) {
        await runCommand('chmod', ['+x', scriptPath]);
      }

      await (Platform.isWindows
          ? runCommand('cmd.exe', ['/c', scriptPath])
          : runCommand('/bin/sh', ['-c', scriptPath]));
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
    if (_isDesktopPlatform()) {
      debugPrint("\t[ running on desktop ]");
      bool monsterIsInstalled = await checkIfCommandExists('topos');
      if (monsterIsInstalled) {
        if (!autoTurnOn) return true;
        try {
          debugPrint("\t[ turning the monster on ]");
          var result = await turnToposOn(apiConfig.getDefault());
          print('Monster is running at ${result['url']}');
          return true;
        } catch (e) {
          print('Failed to run Monster: $e');
          return false;
        }
      } else {
        print('Monster is not installed.');
        return false;
      }
    } else {
      fToast.init(navigatorKey.currentContext!);
      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red[200],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check),
            SizedBox(width: 12.0),
            Text("Must Install on Desktop"),
          ],
        ),
      );
      fToast.showToast(
        child: toast,
        toastDuration: const Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            top: 16.0,
            right: 16.0,
            child: child,
          );
        },
      );
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
