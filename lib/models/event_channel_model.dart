class EventGenerationResponse {
  final double progress;
  final String generation;
  final double toksPerSec;
  final double completionTime;

  const EventGenerationResponse(
      {this.progress = 0,
      this.generation = "",
      this.toksPerSec = 0,
      this.completionTime = 0});

  EventGenerationResponse.fromMap(Map<String, dynamic> data)
      : this(
            progress: data['progress'],
            generation: data['generation'],
            toksPerSec: data['tokensPerSecond'],
            completionTime: data['completionTime']);
}
