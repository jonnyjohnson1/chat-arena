// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:chat/models/event_channel_model.dart';
// import 'package:chat/models/models.dart';

// import '../models/messages.dart';
// import 'ml/swift_ml_plugin.dart';

// class SwiftFunctionsInterface {
//   late final _mlGenerationPlugin;

//   // streaming generations *event* channel: events streams events
//   // event channel is used to stream the model's returned tokens
//   final EventChannel eventMLGenerationsChannel =
//       const EventChannel('Generations');

//   final EventChannel eventModelDownloadSubsChannel =
//       const EventChannel('event.DownloadState.Stream');

//   // streaming generations *method* channel: triggers methods
//   // method channel is used to init and close the stream
//   final mlGenChannel = const MethodChannel('init.Generation.Channel');

//   // is the generation stream active
//   bool streamIsRunning = false;
//   StreamSubscription? generationsSubscription;

//   SwiftFunctionsInterface() {
//     // init the ml model channel
//     _mlGenerationPlugin = MLGenerationPlugin();
//   }

//   StreamSubscription? modelDownloadStateSubscription;

//   ///
//   ///
//   ///
//   /// Model Channel functions here
//   ///
//   ///
//   ///
//   ///

//   // adds the model to swift (downloads config file and params file)
//   // returns the full config from swift
//   Future<Map<String, dynamic>> addModel(String modelURL) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.addModel(modelURL) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // selects the model to use for chat
//   Future<Map<String, dynamic>> selectModel(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.selectModel(modelConfig) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // selects the model to use for chat
//   Future<Map<String, dynamic>> loadMessagesIntoModel(
//       List<Message> messages) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.loadMessagesIntoModel(messages) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // downloads the model
//   Future<Map<String, dynamic>> downloadModel(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.downloadModel(modelConfig) ?? false;
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // downloads the model
//   Future<Map<String, dynamic>> pauseDownload(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.pauseDownload(modelConfig) ?? false;
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // removes the model from memory
//   Future<Map<String, dynamic>> clearModel(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.clearModel(modelConfig) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // removes the model from memory
//   Future<Map<String, dynamic>> deleteModel(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.deleteModel(modelConfig) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // removes the model from memory
//   Future<Map<String, dynamic>> unloadModel(ModelConfig modelConfig) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.unloadModel(modelConfig) ?? {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   // synchs models from
//   Future<Map<String, dynamic>> syncModelsListWithDevice(
//       List<ModelConfig> modelConfigs) async {
//     try {
//       Map<String, dynamic> result =
//           await _mlGenerationPlugin.syncModelsListWithDevice(modelConfigs) ??
//               {};
//       return result;
//     } on PlatformException {
//       debugPrint("PlatformException:");
//       return {"error": "Platform exception"};
//     }
//   }

//   ///
//   ///
//   ///
//   /// Model Channel functions here
//   ///
//   ///
//   ///
//   ///

//   // wrap the stream with a method so that a method can trigger the gen token function
//   // but use a stream to

//   initGenerationStream(String message, dynamic _onEventCallback) async {
//     // stop any generation that might be occurring prior to starting a new one
//     await stopGenerationStream();
//     try {
//       Map<dynamic, dynamic> result =
//           await mlGenChannel.invokeMethod('initStream');
//       String jsonString = jsonEncode(result);
//       // Decode JSON string into Map<String, dynamic>
//       Map<String, dynamic> eventMap = jsonDecode(jsonString);
//       if (eventMap.containsKey("error")) {
//         debugPrint("Error forming generations");
//         return false;
//       } else if (eventMap.containsKey("result")) {
//         String prompt = "$message\n";
//         generationsSubscription =
//             eventMLGenerationsChannel.receiveBroadcastStream(<String, dynamic>{
//           'message': prompt,
//         }).listen(_onEventCallback, onError: _onError);
//         return true;
//       }
//     } on PlatformException catch (e) {
//       throw ArgumentError('Unable to init stream: ${e.message}');
//     } on MissingPluginException catch (e) {
//       throw ErrorSummary('${e.message}');
//     }
//   }

//   stopGenerationStream() async {
//     if (generationsSubscription != null) {
//       await generationsSubscription!.cancel();
//       generationsSubscription = null;
//     }
//   }

//   resetChat() async {
//     try {
//       Map<dynamic, dynamic> result =
//           await mlGenChannel.invokeMethod('resetChat');
//       return result;
//     } on PlatformException catch (e) {
//       throw ArgumentError('Unable to init stream: ${e.message}');
//     } on MissingPluginException catch (e) {
//       throw ErrorSummary('${e.message}');
//     }
//   }

//   stopStream() async {
//     print("invoking the stop steram method");
//     try {
//       Map<dynamic, dynamic> result =
//           await mlGenChannel.invokeMethod('stopStream');
//       return result;
//     } on PlatformException catch (e) {
//       throw ArgumentError('Unable to init stream: ${e.message}');
//     } on MissingPluginException catch (e) {
//       throw ErrorSummary('${e.message}');
//     }
//   }

//   // model download state stream
//   subscribeToModelDownloadStream(dynamic _onEventCallback) async {
//     // stop any generation that might be occurring prior to starting a new one
//     await stopModelDownloadStream();
//     try {
//       modelDownloadStateSubscription = eventModelDownloadSubsChannel
//           .receiveBroadcastStream()
//           .listen(_onEventCallback, onError: _onError);
//       return true;
//     } on PlatformException catch (e) {
//       throw ArgumentError('Unable to init stream: ${e.message}');
//     } on MissingPluginException catch (e) {
//       throw ErrorSummary('${e.message}');
//     }
//   }

//   stopModelDownloadStream() async {
//     if (modelDownloadStateSubscription != null) {
//       await modelDownloadStateSubscription!.cancel();
//       modelDownloadStateSubscription = null;
//     }
//   }

//   //

//   EventGenerationResponse _onError(Object error) {
//     return const EventGenerationResponse(
//         generation: "Error producing generation", progress: 1.0);
//   }
// }
