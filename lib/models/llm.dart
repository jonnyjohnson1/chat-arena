class ModelConfig {
  LanguageModel model;
  double temperature;
  int numGenerations;

  ModelConfig({
    this.model =
        const LanguageModel(model: "solar", name: "solar", size: 21314),
    this.temperature = 0.06,
    this.numGenerations = 1,
  });

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      model: LanguageModel.fromJson(json['model']),
      temperature: json['temperature'] ?? 0.06,
      numGenerations: json['numGenerations'] ?? 1,
    );
  }

  Map<String, dynamic> toDict() {
    return {
      'model': model.toJson(),
      'temperature': temperature,
      'numGenerations': numGenerations,
    };
  }
}

class LanguageModel {
  final String? type;
  final String name;
  final String model;
  final DateTime? modifiedAt;
  final int? size;
  final String? digest;
  final Map<String, dynamic>? details;

  const LanguageModel({
    this.type,
    required this.name,
    required this.model,
    this.modifiedAt,
    this.size,
    this.digest,
    this.details,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    // json['details']['parent_model'] = if
    //     json['details']['parent_model'] ?? json['details']['family'];
    return LanguageModel(
      name: json['name'] ?? json['model'],
      model: json['model'] ?? json['name'],
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : DateTime.now(),
      size: json['size'] ?? 21314,
      digest: json['digest'],
      // details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'model': model,
      'modified_at': modifiedAt?.toIso8601String(),
      'size': size,
      'digest': digest,
      'details': details,
    };
  }
}

String sizeToGB(size) {
  if (size < 0) return 'Invalid size';

  const int kiloBytes = 1024;
  const int megaBytes = kiloBytes * kiloBytes;
  const int gigaBytes = megaBytes * kiloBytes;

  if (size < megaBytes) {
    return '${(size / kiloBytes).toStringAsFixed(2)} KB';
  } else if (size < gigaBytes) {
    return '${(size / megaBytes).toStringAsFixed(2)} MB';
  } else {
    return '${(size / gigaBytes).toStringAsFixed(2)} GB';
  }
}
