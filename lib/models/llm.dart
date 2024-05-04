import 'package:chat/models/model_loaded_states.dart';

class LLM {
  ModelLoadedState? modelLoaded;
  String? modelName;
  String? modelType;
  String? url;

  LLM({
    this.modelLoaded,
    this.modelName,
    this.modelType,
    this.url,
  });
}
