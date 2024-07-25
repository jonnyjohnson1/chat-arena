// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ToposCLInstaller {
//   final ValueNotifier<List<String>> outputNotifier =
//       ValueNotifier<List<String>>([]);

//   void _addOutput(String data) {
//     outputNotifier.value = List.from(outputNotifier.value)..add(data);
//     outputNotifier.notifyListeners();
//     if (data.trim() == "Installation complete!") {
//       Future.delayed(const Duration(seconds: 2), () {
//         outputNotifier.value.clear();
//         outputNotifier.notifyListeners();
//       });
//     }
//   }

//   Future<bool> checkIfCommandExists(String command) async {
//     try {
//       var result = await Process.run('which', [command]);
//       return result.stdout.toString().isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> runCommand(String executable, List<String> arguments) async {
//     var process = await Process.start(executable, arguments);
//     process.stdout.transform(utf8.decoder).listen((data) {
//       debugPrint(data);
//       _addOutput(data);
//     });
//     process.stderr.transform(utf8.decoder).listen((data) {
//       debugPrint(data);
//       _addOutput(data);
//     });

//     var exitCode = await process.exitCode;
//     if (exitCode != 0) {
//       throw ProcessException(executable, arguments,
//           'Command failed with exit code $exitCode', exitCode);
//     }
//     print('$executable ${arguments.join(' ')} executed successfully.');
//   }

//   Future<void> runCommandWithPassword(String executable, List<String> arguments,
//       {Map<String, String>? environment}) async {
//     var process =
//         await Process.start(executable, arguments, environment: environment);

//     process.stdout.transform(utf8.decoder).listen((data) {
//       debugPrint(data);
//       // Add output handling logic here if needed
//     });

//     process.stderr.transform(utf8.decoder).listen((data) {
//       debugPrint(data);
//       // Add error handling logic here if needed
//     });

//     var exitCode = await process.exitCode;
//     if (exitCode != 0) {
//       throw ProcessException(executable, arguments,
//           'Command failed with exit code $exitCode', exitCode);
//     }
//     print('$executable ${arguments.join(' ')} executed successfully.');
//   }

//   Future<bool> checkToposInstalled() async {
//     bool toposInstalled = await checkIfCommandExists('topos');
//     return toposInstalled;
//   }

//   Future<bool> killServer(String httpAddress) async {
//     try {
//       final response = await http.post(Uri.parse('$httpAddress/shutdown'));
//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         // debugPrint("Unexpected status code: ${response.statusCode}");
//         return false;
//       }
//     } on http.ClientException catch (e) {
//       // debugPrint("Client exception: $e");
//       return false;
//     } on SocketException catch (e) {
//       // debugPrint("Socket exception: $e");
//       return false;
//     } on FormatException catch (e) {
//       // debugPrint("Format exception: $e");
//       return false;
//     } catch (e) {
//       // debugPrint("Unexpected error: $e");
//       return false;
//     }
//   }

//   Future<Map<String, dynamic>> turnToposOn(String httpAddress) async {
//     var process = await Process.start('topos', ['run']);
//     var urlCompleter = Completer<String>();
//     var isRunning = false;
//     // await process.stderr.transform(utf8.decoder).forEach(print);
//     process.stdout.transform(utf8.decoder).listen((data) async {
//       // print("LISTENING TO STDOUT");
//       // print(data);
//       _addOutput(data);
//       // Check if the process has started and capture the URL
//       if (data.contains('Uvicorn running on')) {
//         var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
//         if (match != null) {
//           urlCompleter.complete(match.group(0));
//           isRunning = true;
//         }
//       }
//       if (data.contains("address already in use")) {
//         await killServer(httpAddress);
//         await runCommand('topos', ['run']);
//       }
//     });

//     process.stderr.transform(utf8.decoder).listen((data) async {
//       // print("LISTENING TO STDERR");
//       // print(data);
//       _addOutput(data);
//       if (data.contains('Uvicorn running on')) {
//         var match = RegExp(r'http://\d+\.\d+\.\d+\.\d+:\d+').firstMatch(data);
//         if (match != null) {
//           urlCompleter.complete(match.group(0));
//           isRunning = true;
//         }
//       }
//       if (data.contains("address already in use")) {
//         print("\t[ address is in use :: killing process and restarting ]");
//         await killServer(httpAddress);
//         await runCommand('topos', ['run']);
//       }
//     });

//     // Wait for the URL to be captured or for a timeout
//     var url = await urlCompleter.future.timeout(const Duration(seconds: 8),
//         onTimeout: () {
//       throw TimeoutException('Failed to start Topos within the timeout period');
//     });

//     // Check if the process is running
//     if (!isRunning) {
//       throw Exception('Failed to start Topos');
//     }

//     return {'isRunning': isRunning, 'url': url};
//   }

//   Future<bool> stopToposService(String httpAddress) async {
//     try {
//       bool killResult = await killServer(httpAddress);
//       return killResult;
//     } catch (e) {
//       print('Failed to stop Topos service: $e');
//       return false;
//     }
//   }

//   Future<void> runInstallScript() async {
//     try {
//       // Determine the script path based on the OS
//       String scriptPath;
//       if (Platform.isWindows) {
//         scriptPath = '${Directory.current.path}\\scripts\\install_windows.bat';
//       } else if (Platform.isLinux || Platform.isMacOS) {
//         scriptPath = '${Directory.current.path}/scripts/install.sh';
//       } else {
//         throw UnsupportedError('Unsupported platform');
//       }

//       // Make the script executable on Unix-like systems (only needed once)
//       if (!Platform.isWindows) {
//         await runCommand('chmod', ['+x', scriptPath]);
//       }

//       // Run the script using the appropriate shell
//       await (Platform.isWindows
//           ? runCommand('cmd.exe', ['/c', scriptPath])
//           : runCommand('/bin/sh', ['-c', scriptPath]));
//     } catch (e) {
//       print('Error running script: $e');
//     }
//   }

//   Future<void> runSpinInstallScript(String password) async {
//     try {
//       debugPrint("running install");
//       // Determine the script path based on the OS
//       String scriptPath;
//       if (Platform.isWindows) {
//         scriptPath =
//             '${Directory.current.path}\\scripts\\spin\\install_windows.bat';
//       } else if (Platform.isLinux || Platform.isMacOS) {
//         scriptPath = '${Directory.current.path}/scripts/spin/install.sh';
//       } else {
//         throw UnsupportedError('Unsupported platform');
//       }

//       // Make the script executable on Unix-like systems (only needed once)
//       if (!Platform.isWindows) {
//         // Now run the install.sh script with the environment variable
//         try {
//           await runCommandWithPassword(
//             'bash',
//             ['-c', scriptPath],
//             environment: {'PASSWORD': password},
//           );
//         } catch (e) {
//           debugPrint("Failed to run $scriptPath ${e.toString()}");
//         }
//       }
//     } catch (e) {
//       print('Error running script: $e');
//     }
//   }

//   // CHECK FOR UPDATES
//   // THIS WILL BE ALLOWED WHEN WE MAKE THE REPO PUBLIC
//   static const String githubApiUrl =
//       'https://api.github.com/repos/{owner}/{repo}/git/refs/heads/{branch}';

//   static const String owner = 'jonnyjohnson1';
//   static const String repo = 'topos-cli';
//   static const String branch = 'main'; // or any branch you want to check
//   static const String commitHashKey = 'last_commit_hash';
// // https://api.github.com/repos/jonnyjohnson1/topos-cli/commits/main
//   Future<String> _getLatestCommitHash() async {
//     final url = githubApiUrl
//         .replaceAll('{owner}', owner)
//         .replaceAll('{repo}', repo)
//         .replaceAll('{branch}', branch);
//     final response = await http.get(Uri.parse(url));
//     print(response.statusCode);
//     if (response.statusCode != 200) {
//       throw Exception('Failed to load latest commit hash');
//     }

//     final commitData = jsonDecode(response.body);
//     return commitData['sha'];
//   }

//   Future<String?> _readLocalCommitHash() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(commitHashKey);
//   }

//   Future<void> _writeLocalCommitHash(String commitHash) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(commitHashKey, commitHash);
//   }

//   Future<void> checkForUpdates() async {
//     final latestCommitHash = await _getLatestCommitHash();
//     final localCommitHash = await _readLocalCommitHash();

//     if (localCommitHash == null) {
//       print('No local commit hash found. Saving the latest commit hash.');
//       await _writeLocalCommitHash(latestCommitHash);
//       return;
//     }

//     if (latestCommitHash != localCommitHash) {
//       print('Update available!');
//       print('Latest commit hash: $latestCommitHash');
//       print('Local commit hash: $localCommitHash');
//       // Here you can add logic to pull the latest changes or notify the user
//     } else {
//       print('No update available.');
//     }

//     // Update local commit hash
//     await _writeLocalCommitHash(latestCommitHash);
//   }
// }
