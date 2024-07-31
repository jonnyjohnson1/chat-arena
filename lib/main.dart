import 'package:chat/pages/home_scaffold/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:serious_python/serious_python.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FFI
  startPython();
  sqfliteFfiInit();
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  }

  return runApp(const MyApp());
}

void startPython() async {
  SeriousPython.run("app/app.zip", environmentVariables: {"a": "1", "b": "2"});
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//     return MaterialApp(
//       title: 'Chat Arena',
//       debugShowCheckedModeBanner: false,
//       builder: FToastBuilder(),
//       theme: ThemeData(
//           useMaterial3: true,
//           textSelectionTheme: const TextSelectionThemeData(
//               selectionColor: Color.fromARGB(255, 190, 168, 255))),
//       home: MultiProvider(
//           providers: [Provider.value(value: navigatorKey)],
//           child: const HomePage()),
//       navigatorKey: navigatorKey,
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controller;
  String? _result;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    getServiceResult();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getServiceResult() async {
    while (true) {
      try {
        var response = await http.get(Uri.parse("http://127.0.0.1:55001"));
        setState(() {
          _result = response.body;
        });
        return;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? result;
    if (_result != null) {
      result = Text(_result!);
    } else {
      result = const CircularProgressIndicator();
    }

    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Python REPL'),
          ),
          body: SafeArea(
              child: Column(children: [
            Expanded(
              child: Center(
                child: result,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Python code',
                    ),
                    smartQuotesType: SmartQuotesType.disabled,
                    smartDashesType: SmartDashesType.disabled,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 10,
                    enabled: _result != null,
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: _result != null
                          ? () {
                              setState(() {
                                _result = null;
                              });
                              http
                                  .post(
                                      Uri.parse(
                                          "http://127.0.0.1:55001/python"),
                                      headers: {
                                        'Content-Type': 'application/json'
                                      },
                                      body: json.encode(
                                          {"command": _controller.text}))
                                  .then((resp) => setState(() {
                                        _controller.text = "";
                                        _result = resp.body;
                                      }));
                            }
                          : null,
                      child: const Text("Run"))
                ],
              ),
            )
          ]))),
    );
  }
}
