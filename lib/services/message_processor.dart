import 'dart:async';
import 'package:chat/models/messages.dart';

class BackendService {
  Future<Map<String, dynamic>> sendMessage(Message message) async {
    // Simulate sending message to the backend and getting a response
    await Future.delayed(Duration(seconds: 1));
    return {'processedData': 'Processed: ${message.message!.value}'};
  }

  Future<Map<String, dynamic>> receiveMessage(Message message) async {
    // Simulate receiving message from the backend and getting a response
    await Future.delayed(Duration(seconds: 1));
    return {'processedData': 'Received: ${message.message!.value}'};
  }
}

class QueueProcess {
  Function function; // function to process
  Map<String, dynamic>? args; // arguments

  QueueProcess({
    required this.function,
    this.args,
  });

  dynamic execute() {
    print("[ executing function ]");
    if (args != null) {
      // Convert the map of arguments to a list of values
      final positionalArgs = args!.values.toList();
      // final symbolArgs =
      //     args!.map((key, value) => MapEntry(Symbol(key), value));
      return Function.apply(function, positionalArgs, {});
    } else {
      return function();
    }
  }
}

class MessageProcessor {
  // final BackendService backendService;
  final StreamController<QueueProcess> _processingQueueController =
      StreamController();
  int _numberOfProcesses = 0;

  MessageProcessor() {
    _processQueue();
  }

  int get numberOfProcesses => _numberOfProcesses;

  void addProcess(QueueProcess process) {
    print("Adding process");
    _processingQueueController.add(process);
    _numberOfProcesses++;
    print("Processes remain: $_numberOfProcesses");
  }

  Future<dynamic> _validateAndExecuteFunction(QueueProcess queueProcess) async {
    try {
      if (queueProcess.function == null) {
        throw Exception("Function is not set.");
      }

      if (!(queueProcess.function is Function)) {
        throw Exception("Invalid function type.");
      }

      if (queueProcess.args != null && !(queueProcess.args is Map)) {
        throw Exception("Arguments must be a Map.");
      }

      return await queueProcess.execute();
    } catch (e) {
      print("Error: ${e.toString()}");
      return null;
    }
  }

  void _processQueue() async {
    await for (var queueProcess in _processingQueueController.stream) {
      await _validateAndExecuteFunction(queueProcess);
      _numberOfProcesses--;
      print("Processes remain: $_numberOfProcesses");
      if (_numberOfProcesses == 0) {
        print("Setting delay for progress bar to close");
        Future.delayed(const Duration(seconds: 1), () {
          print("Setting progress bar to close");
          // Add your progress bar logic here if necessary
        });
      }
    }
  }
}
