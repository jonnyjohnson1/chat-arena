enum ModelDownloadState {
  initializing,
  indexing,
  paused,
  downloading,
  pausing,
  verifying,
  finished,
  failed,
  clearing,
  deleting,
}

class ModelConfig {
  final String? modelLib;
  final String? localID;
  final List<String>? tokenizerFiles;
  final String? internalDisplayName;
  final double? progress;
  int? internalEstimatedVRAMReq;
  ModelDownloadState? modelDownloadState;

  ModelConfig({
    this.modelLib,
    this.localID,
    this.tokenizerFiles,
    this.internalDisplayName,
    this.progress,
    this.internalEstimatedVRAMReq,
    this.modelDownloadState,
  });

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
        modelLib: json['model_url'] as String,
        localID: json['local_id'] as String,
        tokenizerFiles: json['tokenizer_files'],
        internalDisplayName: json['display_name'] as String?,
        internalEstimatedVRAMReq: json['estimated_vram_req'] as int?,
        progress: json['progress']);
  }

  ModelConfig fromMap(Map<String, dynamic> map) {
    return ModelConfig(
        modelLib: map['modelLib'] ?? '',
        localID: map['localID'] ?? '',
        tokenizerFiles: (map['tokenizerFiles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        internalDisplayName: map['internalDisplayName'] ?? '',
        internalEstimatedVRAMReq: map['internalEstimatedVRAMReq'] as int?,
        modelDownloadState: map['modelDownloadState'] != null
            ? getStateFromString(map['modelDownloadState'].toString())
            : null,
        progress: map['progress'] ?? 0.0);
  }

  String get displayName => internalDisplayName ?? localID!.split('-').first;

  int get estimatedVRAMReq => internalEstimatedVRAMReq ?? 4000000000;
  ModelDownloadState getStateFromString(String stateString) {
    switch (stateString) {
      case "initializing":
        return ModelDownloadState.initializing;
      case "indexing":
        return ModelDownloadState.indexing;
      case "paused":
        return ModelDownloadState.paused;
      case "downloading":
        return ModelDownloadState.downloading;
      case "pausing":
        return ModelDownloadState.pausing;
      case "verifying":
        return ModelDownloadState.verifying;
      case "finished":
        return ModelDownloadState.finished;
      case "failed":
        return ModelDownloadState.failed;
      case "clearing":
        return ModelDownloadState.clearing;
      case "deleting":
        return ModelDownloadState.deleting;
      default:
        // You may want to handle unknown states appropriately, e.g., return a default state or throw an exception.
        return ModelDownloadState.initializing;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'model_url': modelLib,
      'local_id': localID,
      'tokenizer_files': tokenizerFiles,
      'display_name': internalDisplayName,
      'estimated_vram_req': internalEstimatedVRAMReq,
      'progress': progress
    };
  }
}
