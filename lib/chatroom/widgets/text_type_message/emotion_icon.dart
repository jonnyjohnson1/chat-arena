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
        return _buildEmoji("👍", _getColor(Colors.blue, score), "Admiration");
      case 'amusement':
        return _buildEmoji("😂", _getColor(Colors.orange, score), "Amusement");
      case 'anger':
        return _buildEmoji("😠", _getColor(Colors.red, score), "Anger");
      case 'annoyance':
        return _buildEmoji("😒", _getColor(Colors.yellow, score), "Annoyance");
      case 'approval':
        return _buildEmoji("👌", _getColor(Colors.green, score), "Approval");
      case 'caring':
        return _buildEmoji("❤️", _getColor(Colors.pink, score), "Caring");
      case 'confusion':
        return _buildEmoji("😕", _getColor(Colors.grey, score), "Confusion");
      case 'curiosity':
        return _buildEmoji("🤔", _getColor(Colors.teal, score), "Curiosity");
      case 'desire':
        return _buildEmoji("😍", _getColor(Colors.redAccent, score), "Desire");
      case 'disappointment':
        return _buildEmoji(
            "😞", _getColor(Colors.brown, score), "Disappointment");
      case 'disapproval':
        return _buildEmoji(
            "👎", _getColor(Colors.deepOrange, score), "Disapproval");
      case 'disgust':
        return _buildEmoji("🤢", _getColor(Colors.lime, score), "Disgust");
      case 'embarrassment':
        return _buildEmoji(
            "😳", _getColor(Colors.purple, score), "Embarrassment");
      case 'excitement':
        return _buildEmoji(
            "🤩", _getColor(Colors.lightGreen, score), "Excitement");
      case 'fear':
        return _buildEmoji("😨", _getColor(Colors.indigo, score), "Fear");
      case 'gratitude':
        return _buildEmoji("🙏", _getColor(Colors.cyan, score), "Gratitude");
      case 'grief':
        return _buildEmoji("😭", _getColor(Colors.black, score), "Grief");
      case 'joy':
        return _buildEmoji("😊", _getColor(Colors.yellow, score), "Joy");
      case 'love':
        return _buildEmoji("❤️", _getColor(Colors.red, score), "Love");
      case 'nervousness':
        return _buildEmoji(
            "😬", _getColor(Colors.orange, score), "Nervousness");
      case 'optimism':
        return _buildEmoji("😃", _getColor(Colors.green, score), "Optimism");
      case 'pride':
        return _buildEmoji("😌", _getColor(Colors.purple, score), "Pride");
      case 'realization':
        return _buildEmoji("💡", _getColor(Colors.amber, score), "Realization");
      case 'relief':
        return _buildEmoji("😌", _getColor(Colors.lightBlue, score), "Relief");
      case 'remorse':
        return _buildEmoji("😔", _getColor(Colors.blueGrey, score), "Remorse");
      case 'sadness':
        return _buildEmoji("😢", _getColor(Colors.blue, score), "Sadness");
      case 'surprise':
        return _buildEmoji(
            "😲", _getColor(Colors.pinkAccent, score), "Surprise");
      case 'neutral':
        return _buildEmoji("😐", _getColor(Colors.grey, score), "Neutral");
      default:
        return _buildEmoji("❓", Colors.grey, "Unknown");
    }
  }

  Color _getColor(Color baseColor, double score) {
    return baseColor.withOpacity(score);
  }

  Widget _buildEmoji(String emoji, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
      ),
    );
  }
}
