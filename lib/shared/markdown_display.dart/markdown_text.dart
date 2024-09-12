// import 'package:chat/shared/markdown_display.dart/code_wrapper.dart';
// import 'package:flutter/material.dart';
// import 'package:markdown_widget/config/configs.dart';
// import 'package:markdown_widget/widget/all.dart';

// class MarkdownText extends StatefulWidget {
//   final String text;
//   final BuildContext context;
//   final TextStyle? style;
//   const MarkdownText(this.text, this.context, {this.style, super.key});

//   @override
//   State<MarkdownText> createState() => _MarkdownTextState();
// }

// class _MarkdownTextState extends State<MarkdownText> {
//   Widget buildMarkdown(BuildContext context, String string) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final config = MarkdownConfig.defaultConfig;
//     final codeWrapper =
//         (child, text, language) => CodeWrapperWidget(child, text, language);
//     return IntrinsicHeight(
//       child: MarkdownBlock(
//           data: string,
//           selectable: true,
//           config: config.copy(configs: [
//             if (widget.style != null)
//               PConfig(
//                 textStyle: widget.style!,
//               ),
//             PreConfig().copy(
//               wrapper: codeWrapper,
//               // textStyle: widget.style!,
//             )
//           ])),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return buildMarkdown(widget.context, widget.text);
//   }
// }
