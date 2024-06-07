import 'package:flutter/material.dart';

class ModeratorIcon extends StatelessWidget {
  final String label;
  final String? name;
  final double size;

  ModeratorIcon({required this.label, required this.name, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return _getWidgetForLabel(label);
  }

  Widget _getWidgetForLabel(String label) {
    switch (label) {
      case 'S':
        return _buildIcon(Icons.favorite, Colors.pink, "Sexual");
      case 'H':
        return _buildIcon(Icons.block, Colors.red, "Hate");
      case 'V':
        return _buildIcon(Icons.warning, Colors.orange, "Violence");
      case 'HR':
        return _buildIcon(Icons.report_problem, Colors.yellow, "Harassment");
      case 'SH':
        return _buildIcon(Icons.healing, Colors.purple, "Self-harm");
      case 'S3':
        return _buildIcon(Icons.child_care, Colors.pinkAccent, "Sexual/minors");
      case 'H2':
        return _buildIcon(Icons.warning, Colors.deepOrange, "Hate/threatening");
      case 'V2':
        return _buildIcon(Icons.gavel, Colors.redAccent, "Violence/graphic");
      case 'OK':
        return _buildIcon(Icons.check_circle_outline_sharp, Colors.green, "OK");
      default:
        return _buildIcon(Icons.help, Colors.grey, "Unknown");
    }
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
