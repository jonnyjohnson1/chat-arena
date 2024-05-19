import 'package:flutter/material.dart';

class SentimentIcon extends StatelessWidget {
  final String sentiment;
  final double score;
  final double size;

  SentimentIcon({required this.sentiment, this.score = 1, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return _getWidgetForSentiment(sentiment, score);
  }

  Widget _getWidgetForSentiment(String sentiment, double score) {
    switch (sentiment) {
      case 'POS':
        return _buildIcon(
            Icons.add, _getColor(Colors.black87, score), "Positive");
      case 'NEG':
        return _buildIcon(
            Icons.remove, _getColor(Colors.black87, score), "Negative");
      case 'NEU':
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
