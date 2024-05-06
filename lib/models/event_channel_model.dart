class EventGenerationResponse {
  final String generation;
  final double toksPerSec;
  final double completionTime;
  final bool isCompleted;

  const EventGenerationResponse(
      {this.generation = "",
      this.toksPerSec = 0,
      this.completionTime = 0,
      this.isCompleted = true});

  EventGenerationResponse.fromMap(Map<String, dynamic> data)
      : generation = data['response'] ?? "",
        toksPerSec = data['toksPerSec'] ?? 0,
        completionTime = data['completionTime'] ?? 0,
        isCompleted = data['status'] == 'completed';
}
