import 'package:chat/shared/activity_icon.dart';
import 'package:flutter/material.dart';

class ServiceToggle extends StatefulWidget {
  bool isConnected;
  Function? onTap;
  ServiceToggle({required this.isConnected, required this.onTap, super.key});
  @override
  _ServiceToggleState createState() => _ServiceToggleState();
}

class _ServiceToggleState extends State<ServiceToggle> {
  @override
  void initState() {
    super.initState();
  }

  void _toggleService() {
    widget.isConnected = !widget.isConnected;
    widget.onTap!(widget.isConnected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap != null ? _toggleService : null,
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            ActivityIcon(isRunning: widget.isConnected),
            const SizedBox(
              width: 4,
            ),
            Text(widget.isConnected ? "connected" : "connect"),
          ],
        ),
      ),
    );
  }
}
