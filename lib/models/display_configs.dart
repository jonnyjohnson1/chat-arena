import 'dart:convert';
import 'package:chat/models/llm.dart';
import 'package:chat/services/static_queries.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/function_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayConfigData {
  bool showInMessageNER;
  bool calculateInMessageNER;
  bool showModerationTags;
  bool calculateModerationTags;
  bool showSidebarBaseAnalytics;
  bool calcImageGen;
  bool calcMsgMermaidChart;
  bool calcConvMermaidChart;
  bool demoMode;
  APIConfig apiConfig;

  DisplayConfigData({
    this.showInMessageNER = true,
    this.calculateInMessageNER = true,
    this.showModerationTags = true,
    this.calculateModerationTags = true,
    this.showSidebarBaseAnalytics = true,
    this.calcImageGen = false,
    this.calcMsgMermaidChart = false,
    this.calcConvMermaidChart = false,
    this.demoMode = false,
  }) : apiConfig = APIConfig();

  Map<String, bool> toMap() {
    return {
      'showInMessageNER': showInMessageNER,
      'calculateInMessageNER': calculateInMessageNER,
      'showModerationTags': showModerationTags,
      'calculateModerationTags': calculateModerationTags,
      'showSidebarBaseAnalytics': showSidebarBaseAnalytics,
      'calculateImageGen': calcImageGen,
      'calcMsgMermaidChart': calcMsgMermaidChart,
      'calcConvMermaidChart': calcConvMermaidChart,
      'demoMode': demoMode
    };
  }
}

class APIConfig {
  String defaultBackendEndpoint;
  String customBackendEndpoint;
  String defaultP2PChatEndpoint;
  String customP2PChatEndpoint;

  // Provider api keys
  String openAiApiKey;
  String groqApiKey;

  bool openAiKeyWorks;
  bool groqKeyWorks;

  List<LanguageModel> openAIModels = [];
  List<LanguageModel> groqModels = [];

  // Function services
  late FunctionServices functions;

  APIConfig({
    this.defaultBackendEndpoint = "http://0.0.0.0:13341",
    this.customBackendEndpoint = "",
    this.defaultP2PChatEndpoint = "http://127.0.0.1:13394",
    this.customP2PChatEndpoint = "",

    // provider api keys
    this.openAiApiKey = "",
    this.groqApiKey = "",
    this.openAiKeyWorks = false,
    this.groqKeyWorks = false,
  }) {
    functions = FunctionServices.initEmpty();
    _loadFunctionServices();
    _loadAPIKeys();
  }

  Future<void> _loadAPIKeys() async {
    // Get the instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the API key from SharedPreferences
    String? apiKey = prefs.getString('openai_apikey');
    String? groqKey = prefs.getString('groq_apikey');
    // If the API key is present, set it to the openAiApiKey variable
    if (apiKey != null) {
      openAiApiKey = apiKey;
      openAiKeyWorks = await testOpenAIApiKey(apiKey);
    }

    if (groqKey != null) {
      groqApiKey = groqKey;
      groqKeyWorks = await testGroqApiKey(groqApiKey);
    }
  }

  // get http => null;

  Future<void> _loadFunctionServices() async {
    functions = await FunctionServices.initialize();
  }

  void setSecure() {
    if (defaultBackendEndpoint.startsWith("http://")) {
      // set backend endpoint
      defaultBackendEndpoint =
          defaultBackendEndpoint.replaceFirst("http://", "https://");
      // set p2p chat endpoint
      defaultP2PChatEndpoint =
          defaultP2PChatEndpoint.replaceFirst("http://", "https://");
    } else if (defaultBackendEndpoint.startsWith("ws://")) {
      // set backend endpoint
      defaultBackendEndpoint =
          defaultBackendEndpoint.replaceFirst("ws://", "wss://");
      // set p2p chat endpoint
      defaultP2PChatEndpoint =
          defaultP2PChatEndpoint.replaceFirst("ws://", "wss://");
    }
  }

  Future<void> setOpenAiApiKey(String apiKey) async {
    // Set the API key
    openAiApiKey = apiKey;

    // Save openAiApiKey to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_apikey', apiKey);
    openAiKeyWorks = await testOpenAIApiKey(openAiApiKey);
  }

  Future<bool> testOpenAIApiKey(String apiKey) async {
    final url = Uri.parse('https://api.openai.com/v1/models');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        openAIModels = formatOpenAIModelsJson(data) ?? [];
        return true;
      } else {
        print('Failed to fetch models. Response code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }

  Future<void> setGroqApiKey(String apiKey) async {
    // Set the API key
    groqApiKey = apiKey;

    // Save openAiApiKey to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_apikey', apiKey);
    groqKeyWorks = await testGroqApiKey(groqApiKey);
  }

  Future<bool> testGroqApiKey(String apiKey) async {
    final url = Uri.parse(
        'https://api.groq.com/openai/v1/models'); // Adjust the URL to match Groq's API endpoint
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        groqModels = formatOpenAIModelsJson(data) ?? [];
        // Extract and return the model IDs
        return true;
      } else {
        print('Failed to fetch models. Response code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }

  String getDefaultLLMBackend() => customBackendEndpoint.isEmpty
      ? defaultBackendEndpoint
      : customBackendEndpoint;

  String getDefaultMessengerBackend() => customBackendEndpoint.isEmpty
      ? defaultP2PChatEndpoint
      : customP2PChatEndpoint;

  bool isLocalhost() {
    final endpoint = getDefaultLLMBackend();
    final uri = Uri.parse(endpoint);
    return uri.host == "0.0.0.0" ||
        uri.host == "localhost" ||
        uri.host.startsWith("127.") ||
        uri.host.endsWith(".local");
  }
}
