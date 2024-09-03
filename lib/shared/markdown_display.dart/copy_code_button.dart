import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyCodeButton extends StatefulWidget {
  final String codeContent;

  const CopyCodeButton({Key? key, required this.codeContent}) : super(key: key);

  @override
  _CopyCodeButtonState createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<CopyCodeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.white70,
      end: Colors.greenAccent,
    ).animate(_controller);
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.codeContent));
    setState(() {
      _copied = true;
    });
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _controller.reverse().then((_) {
          setState(() {
            _copied = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Copy",
      waitDuration: const Duration(milliseconds: 350),
      preferBelow: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _copyCode,
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Row(
                children: [
                  Icon(
                    _copied ? Icons.check : Icons.copy,
                    size: 13,
                    color: _colorAnimation.value,
                  ),
                  const SizedBox(width: 6),
                  SelectionContainer.disabled(
                    child: Text(
                      _copied ? 'Copied!' : 'Copy code',
                      style: TextStyle(
                        color: _colorAnimation.value,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
