class MemoryConfig {
  final double? usedMemory;
  final int? totalMemory;

  MemoryConfig({
    this.usedMemory,
    this.totalMemory,
  });

  factory MemoryConfig.fromJson(Map<String, dynamic> json) {
    return MemoryConfig(
      usedMemory: json['used-memory'] as double?,
      totalMemory: json['total-memory'] as int?,
    );
  }
}
