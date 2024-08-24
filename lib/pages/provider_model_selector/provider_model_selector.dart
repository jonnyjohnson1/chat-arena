import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/shared/model_selector.dart';
import 'package:chat/shared/provider_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderModelSelectorButton extends StatefulWidget {
  final initialProvider;
  final initialModel;
  final onModelChange;
  final onProviderChange;
  const ProviderModelSelectorButton(
      {this.initialProvider,
      this.initialModel,
      this.onProviderChange,
      this.onModelChange,
      super.key});

  @override
  State<ProviderModelSelectorButton> createState() =>
      _ProviderModelSelectorButtonState();
}

class _ProviderModelSelectorButtonState
    extends State<ProviderModelSelectorButton> {
  late LanguageModel selectedModel;
  late String selectedProvider;
  late ValueNotifier<DisplayConfigData> displayConfigData;
  @override
  void initState() {
    selectedProvider = widget.initialProvider ?? "ollama";
    selectedModel = widget.initialModel ??
        const LanguageModel(name: "dolphin-llama3", model: "dolphin-llama3");

    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    // debugPrint("groq: " + displayConfigData.value.apiConfig.groqApiKey);
    // debugPrint("openai: " + displayConfigData.value.apiConfig.openAiApiKey);
    super.initState();
  }

  LanguageModel getInitModel(String provider) {
    switch (provider) {
      case "ollama":
        return const LanguageModel(
            name: "dolphin-llama3", model: "dolphin-llama3");
      case "openai":
        return const LanguageModel(
            name: "gpt-3.5-turbo", model: "gpt-3.5-turbo");
      case "groq":
        return const LanguageModel(
            name: "llama3-70b-8192", model: "llama3-70b-8192");

      default:
        // Return a default model or handle unknown providers
        return const LanguageModel(
            name: "default-model", model: "default-model");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProviderSelector(
          initProvider: selectedProvider,
          onProviderChange: (String provider) {
            if (widget.onProviderChange != null) {
              widget.onProviderChange(provider);
              // TODO reset the list
              setState(() {
                selectedModel = getInitModel(provider);
                selectedProvider = provider;
              });
            }
          },
        ),
        ModelSelector(
          key: Key(selectedProvider),
          provider: selectedProvider,
          initModel: selectedModel,
          onSelectedModelChange: (LanguageModel model) {
            if (widget.onModelChange != null) {
              widget.onModelChange!(model);
            }
          },
        ),
      ],
    );
  }
}
