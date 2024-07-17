import 'dart:async';

import 'package:flutter/material.dart';

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
  final ValueNotifier<int> _numberOfPriorProcesses = ValueNotifier(0);
  final ValueNotifier<int> _numberOfProcesses = ValueNotifier(0);
  final StreamController<bool> _completionStatusController =
      StreamController<bool>.broadcast();
  Future<void> Function()? processDemoCompleteFunction;

  MessageProcessor({this.processDemoCompleteFunction}) {
    _processQueue();
  }

  ValueNotifier<int> get numberOfProcesses => _numberOfProcesses;
  Stream<bool> get completionStatus => _completionStatusController.stream;

  void addProcess(QueueProcess process) {
    _processingQueueController.add(process);
    _numberOfProcesses.value++;
    print("Processes remain: $_numberOfProcesses");
  }

  bool isCompleted() {
    return _numberOfProcesses.value == 0 && _numberOfPriorProcesses.value > 0;
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
      _numberOfPriorProcesses.value = _numberOfProcesses.value;
      _numberOfProcesses.value--;
      print("Processes remain: ${_numberOfProcesses.value}");
      _completionStatusController.add(
          _numberOfProcesses.value == 0 && _numberOfPriorProcesses.value > 0);

      if (_numberOfProcesses.value == 0 && _numberOfPriorProcesses.value > 0) {
        // Trigger your function when processes reach zero
        if (processDemoCompleteFunction != null &&
            _numberOfPriorProcesses.value > 0 &&
            _numberOfProcesses.value == 0) {
          await processDemoCompleteFunction!();
        }
      }
    }
  }

  void dispose() {
    _processingQueueController.close();
    _completionStatusController.close();
  }
}
