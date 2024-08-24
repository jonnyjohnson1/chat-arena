import 'package:chat/pages/home_scaffold/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
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
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      title: 'Chat Arena',
      // scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      theme: ThemeData(
          useMaterial3: true,
          textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Color.fromARGB(255, 190, 168, 255))),
      home: MultiProvider(
          providers: [Provider.value(value: navigatorKey)],
          child: const HomePage()),
      navigatorKey: navigatorKey,
    );
  }
}
