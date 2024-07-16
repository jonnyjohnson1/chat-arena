import 'package:chat/pages/home_scaffold/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FFI
  sqfliteFfiInit();
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  }

  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Color.fromARGB(255, 123, 81, 237))),
      home: const HomePage(),
    );
  }
}
