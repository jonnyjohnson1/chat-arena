// Enum for DemoController states
enum DemoState { generating, next, pause }

class DemoController {
  DemoState state;
  int index;
  int durBetweenMessages = 1400;
  bool isTypeWritten;
  bool autoPlay;

  DemoController(
      {required this.state,
      required this.index,
      required this.durBetweenMessages,
      required this.isTypeWritten,
      required this.autoPlay});

  // Other methods and properties for DemoController can be added here
}
