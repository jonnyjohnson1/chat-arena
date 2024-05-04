import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text('Hello World!'),
              TextButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    print(result!.files.single.path!);

                    if (result != null) {
                      File file = File(result.files.single.path!);
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text("Load File"))
            ],
          ),
        ),
      ),
    );
  }
}
