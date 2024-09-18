import 'package:chat/custom_pkgs/flutter_highlighter/flutter_highlighter.dart';
import 'package:chat/shared/markdown_display.dart/copy_code_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CodeBlockWithFloatingButton extends StatefulWidget {
  final String codeContent;
  final String? codeLanguage;
  final theme;

  const CodeBlockWithFloatingButton({
    Key? key,
    required this.codeContent,
    this.theme,
    this.codeLanguage,
  }) : super(key: key);

  @override
  _CodeBlockWithFloatingButtonState createState() =>
      _CodeBlockWithFloatingButtonState();
}

class _CodeBlockWithFloatingButtonState
    extends State<CodeBlockWithFloatingButton> {
  final GlobalKey _codeBlockKey = GlobalKey();
  double _buttonTopPosition = 8.0;

  void _updateButtonPosition() {
    final RenderBox? renderBox =
        _codeBlockKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      // Calculate the new button position based on the container's position
      double safePadding = MediaQuery.paddingOf(context).top;
      double newButtonTopPosition = position.dy < 0
          ? -1 *
              (MediaQuery.of(context).size.width < 600
                  ? position.dy - safePadding - 112
                  : position.dy - 32)
          : 13.0;
      setState(() {
        _buttonTopPosition = newButtonTopPosition; //.clamp(16.0, 105.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update the button position every time the layout changes
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _updateButtonPosition());

        return Stack(
          key: _codeBlockKey,
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.codeLanguage ?? 'code',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                              width: 48), // Placeholder for the Copy button
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.codeContent.split('\n').map((line) {
                            return HighlightView(
                              line,
                              padding: const EdgeInsets.all(3),
                              language: widget.codeLanguage ?? 'dart',
                              theme: widget.theme,
                              textStyle: const TextStyle(
                                height: 1.16,
                                fontFamily: 'Courier',
                                fontSize: 16.0,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Position the Copy Code Button dynamically based on the layout constraints
            Positioned(
              top: _buttonTopPosition,
              right: 8,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: CopyCodeButton(codeContent: widget.codeContent),
                  )),
            ),
          ],
        );
      },
    );
  }
}
