import 'package:flutter/material.dart';

class DemoModeWidget extends StatefulWidget {
  final String title;
  final bool demoMode;
  final VoidCallback onClose;

  const DemoModeWidget({
    Key? key,
    required this.title,
    required this.demoMode,
    required this.onClose,
  }) : super(key: key);

  @override
  _DemoModeWidgetState createState() => _DemoModeWidgetState();
}

class _DemoModeWidgetState extends State<DemoModeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: null,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: !widget.demoMode
                      ? const Color.fromARGB(0, 255, 255, 255)
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.demoMode)
                        const Row(
                          children: [
                            Icon(
                              Icons.play_lesson_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      Text(
                        widget.demoMode ? "Chat Demo" : widget.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.demoMode && _isHovered)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
