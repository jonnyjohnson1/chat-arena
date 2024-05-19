import 'package:flutter/material.dart';

class EmotionIcon extends StatelessWidget {
  final String emotion;
  final double score;
  final double size;

  EmotionIcon({required this.emotion, required this.score, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return _getWidgetForEmotion(emotion, score);
  }

  Widget _getWidgetForEmotion(String emotion, double score) {
    switch (emotion) {
      case 'admiration':
        return _buildIcon(
            Icons.thumb_up, _getColor(Colors.blue, score), "Admiration");
      case 'amusement':
        return _buildIcon(Icons.sentiment_very_satisfied,
            _getColor(Colors.orange, score), "Amusement");
      case 'anger':
        return _buildIcon(Icons.sentiment_very_dissatisfied,
            _getColor(Colors.red, score), "Anger");
      case 'annoyance':
        return _buildIcon(Icons.sentiment_dissatisfied,
            _getColor(Colors.yellow, score), "Annoyance");
      case 'approval':
        return _buildIcon(
            Icons.thumb_up_alt, _getColor(Colors.green, score), "Approval");
      case 'caring':
        return _buildIcon(
            Icons.favorite, _getColor(Colors.pink, score), "Caring");
      case 'confusion':
        return _buildIcon(Icons.sentiment_neutral,
            _getColor(Colors.grey, score), "Confusion");
      case 'curiosity':
        return _buildIcon(
            Icons.search, _getColor(Colors.teal, score), "Curiosity");
      case 'desire':
        return _buildIcon(Icons.favorite_border,
            _getColor(Colors.redAccent, score), "Desire");
      case 'disappointment':
        return _buildIcon(Icons.sentiment_dissatisfied,
            _getColor(Colors.brown, score), "Disappointment");
      case 'disapproval':
        return _buildIcon(Icons.thumb_down, _getColor(Colors.deepOrange, score),
            "Disapproval");
      case 'disgust':
        return _buildIcon(
            Icons.thumb_down_alt, _getColor(Colors.lime, score), "Disgust");
      case 'embarrassment':
        return _buildIcon(Icons.sentiment_neutral,
            _getColor(Colors.purple, score), "Embarrassment");
      case 'excitement':
        return _buildIcon(Icons.sentiment_very_satisfied,
            _getColor(Colors.lightGreen, score), "Excitement");
      case 'fear':
        return _buildIcon(Icons.sentiment_dissatisfied,
            _getColor(Colors.indigo, score), "Fear");
      case 'gratitude':
        return _buildIcon(
            Icons.thumb_up, _getColor(Colors.cyan, score), "Gratitude");
      case 'grief':
        return _buildIcon(Icons.sentiment_very_dissatisfied,
            _getColor(Colors.black, score), "Grief");
      case 'joy':
        return _buildIcon(
            Icons.sentiment_satisfied, _getColor(Colors.yellow, score), "Joy");
      case 'love':
        return _buildIcon(Icons.favorite, _getColor(Colors.red, score), "Love");
      case 'nervousness':
        return _buildIcon(Icons.sentiment_dissatisfied,
            _getColor(Colors.orange, score), "Nervousness");
      case 'optimism':
        return _buildIcon(
            Icons.thumb_up, _getColor(Colors.green, score), "Optimism");
      case 'pride':
        return _buildIcon(Icons.sentiment_very_satisfied,
            _getColor(Colors.purple, score), "Pride");
      case 'realization':
        return _buildIcon(
            Icons.lightbulb, _getColor(Colors.amber, score), "Realization");
      case 'relief':
        return _buildIcon(Icons.sentiment_satisfied,
            _getColor(Colors.lightBlue, score), "Relief");
      case 'remorse':
        return _buildIcon(Icons.sentiment_dissatisfied,
            _getColor(Colors.blueGrey, score), "Remorse");
      case 'sadness':
        return _buildIcon(Icons.sentiment_very_dissatisfied,
            _getColor(Colors.blue, score), "Sadness");
      case 'surprise':
        return _buildIcon(Icons.sentiment_satisfied,
            _getColor(Colors.pinkAccent, score), "Surprise");
      case 'neutral':
        return _buildIcon(
            Icons.sentiment_neutral, _getColor(Colors.grey, score), "Neutral");
      default:
        return _buildIcon(Icons.help, Colors.grey, "Unknown");
    }
  }

  Color _getColor(Color baseColor, double score) {
    return baseColor.withOpacity(score);
  }

  Widget _buildIcon(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
