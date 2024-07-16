import 'dart:async';

class QueueProcess {
  Function function; // function to process
  Map<String, dynamic>? args; // arguments

  QueueProcess({
    required this.function,
    this.args,
  });

  Future<dynamic> execute() {
    if (args != null) {
      // Convert the map of arguments to a list of values
      final positionalArgs = args!.values.toList();
      // final symbolArgs =
      //     args!.map((key, value) => MapEntry(Symbol(key), value)); // Use to pass the symbolic args into method
      return Function.apply(function, positionalArgs, {});
    } else {
      return function();
    }
  }
}

class MessageProcessor {
  final StreamController<QueueProcess> _processingQueueController =
      StreamController();
  int _numberOfProcesses = 0;
  final Future<void> Function()? processCompleteFunction;
  MessageProcessor({this.processCompleteFunction}) {
    _processQueue();
  }

  int get numberOfProcesses => _numberOfProcesses;

  void addProcess(QueueProcess process) {
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
      if (_numberOfProcesses == 0 && processCompleteFunction != null) {
        // Trigger your function when processes reach zero
        if (_numberOfProcesses == 0 && processCompleteFunction != null) {
          await processCompleteFunction!();
        }
      }

      void _triggerFunctionWhenProcessesZero() {
        // Replace this with your function logic to do something when processes reach zero
        print("All processes completed. Triggering function...");
      }

      void dispose() {
        _processingQueueController.close();
      }
    }
  }
}

// class MessageProcessor {
//   final StreamController<QueueProcess> _processingQueueController =
//       StreamController();
//   int _numberOfProcesses = 0;
//   final Future<void> Function()? processCompleteFunction;

//   MessageProcessor({this.processCompleteFunction});

//   int get numberOfProcesses => _numberOfProcesses;

//   void addProcess(QueueProcess process) {
//     _processingQueueController.add(process);
//     _numberOfProcesses++;
//     print("Processes remain: $_numberOfProcesses");
//   }

//   Future<dynamic> _validateAndExecuteFunction(QueueProcess queueProcess) async {
//     try {
//       if (queueProcess.function == null) {
//         throw Exception("Function is not set.");
//       }

//       if (!(queueProcess.function is Function)) {
//         throw Exception("Invalid function type.");
//       }

//       if (queueProcess.args != null && !(queueProcess.args is Map)) {
//         throw Exception("Arguments must be a Map.");
//       }

//       return await queueProcess.execute();
//     } catch (e) {
//       print("Error: ${e.toString()}");
//       return null;
//     }
//   }

//   void _processQueue() async {
//     await for (var queueProcess in _processingQueueController.stream) {
//       await _validateAndExecuteFunction(queueProcess);
//       _numberOfProcesses--;
//       print("Processes remain: $_numberOfProcesses");
//       if (_numberOfProcesses == 0 && processCompleteFunction != null) {
//         await processCompleteFunction!();
//       }
//     }
//   }

//   void dispose() {
//     _processingQueueController.close();
//   }

//   Stream<QueueProcess> get processingQueueStream =>
//       _processingQueueController.stream;
// }
  