import 'package:chat/custom_pkgs/flutter_highlighter/flutter_highlighter.dart';
import 'package:chat/shared/markdown_display.dart/atom-one-dark.dart';
import 'package:chat/shared/markdown_display.dart/copy_code_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:syntax_highlight/syntax_highlight.dart';

class MarkdownWidget extends StatelessWidget {
  final String data;
  final TextStyle? style;

  MarkdownWidget({
    Key? key,
    required this.data,
    this.style,
  }) : super(key: key);

  HighlighterTheme? theme;
  Highlighter? highlighter;
  initHighligher() async {
    await Highlighter.initialize(['dart', 'yaml', 'sql', 'nix']);
    theme = await HighlighterTheme.loadLightTheme();
    highlighter = Highlighter(
      language: 'nix',
      theme: theme!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initHighligher(),
        builder: (context, snapshot) {
          return MarkdownBody(
            data: data,
            builders: {
              'code': CodeElementBuilder(), // Use the custom builder
            },
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: style,
              h1: style!.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
              h2: style!.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              h3: style!.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              codeblockPadding: const EdgeInsets.all(
                  0), // Remove padding to handle it in the custom widget
              codeblockDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors
                    .transparent, // No background color; handled by highlight
              ),
              listBullet: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              tableHead:
                  style!.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              tableBody:
                  style!.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              tableCellsDecoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
          );
        });
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // To determine whether the code is an inline code block or a code block
    bool isCodeBlock(md.Element element) {
      if (element.attributes['class'] != null) {
        return true;
      } else if (element.textContent.contains("\n")) {
        return true;
      }
      return false;
    }

    final codeLanguage =
        element.attributes['class']?.replaceFirst('language-', '');
    var theme = atomOneDarkTheme;
    final codeContent = element.textContent.trim();

    if (isCodeBlock(element)) {
      Color background = Colors.black87;
      theme['root'] = TextStyle(
          backgroundColor: background,
          color: Color.fromARGB(255, 234, 234, 234));
      return Container(
        width: double.infinity, // Expands to full width
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    codeLanguage ?? 'code',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  CopyCodeButton(codeContent: codeContent),
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
                child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: HighlightView(
                      codeContent,
                      padding: const EdgeInsets.all(3),
                      language: codeLanguage ??
                          'dart', // Default to Dart if no language is specified
                      theme: theme, // Apply the theme
                      textStyle: const TextStyle(
                        height: 1.16,
                        fontFamily: 'Courier', // Use a monospaced font
                        fontSize: 16.0,
                      ),
                    )))
          ],
        ),
      );
    } else {
      Color background = const Color.fromARGB(0, 255, 255, 255);

      return Container(
          // padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[300], // surfaceTint,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
            child: Text(
              codeContent,
              style: TextStyle(
                height: 1.16,
                color: Colors.black.withOpacity(0.9),
                fontFamily: 'Courier', // Use a monospaced font
                fontSize: 16.0,
              ),
            ),
          ));
    }
  }
}
