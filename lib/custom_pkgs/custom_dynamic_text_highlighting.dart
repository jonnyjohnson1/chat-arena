import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

/// It stores the layout data about a word
class WordHighlight {
  final String? label;
  final TextStyle? textStyle;
  final Color color;
  final int? startChar;
  // final bool hasLabel;

  WordHighlight({
    this.label,
    this.textStyle,
    this.startChar,
    this.color = Colors.yellow,
  });
}

class DynamicTextHighlighting extends StatelessWidget {
  //DynamicTextHighlighting
  final String text;
  final Map<String, WordHighlight> highlights;
  // final Map<String, Color>? labelsDict; //
  // final Color color;
  final TextStyle style;
  final bool caseSensitive;

  //RichText
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  DynamicTextHighlighting({
    //DynamicTextHighlighting
    Key? key,
    required this.text,
    required this.highlights,
    // this.color = Colors.yellow,
    // this.labelsDict,
    this.style = const TextStyle(
      color: Colors.black,
    ),
    this.caseSensitive = true,

    //RichText
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  })  : assert(textAlign != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        super(key: key);

  Map<String, WordHighlight> _modHighlights = {};

  @override
  Widget build(BuildContext context) {
    // Controls
    if (text == '') {
      return _richText(_normalSpan(text));
    }
    if (highlights.isEmpty) {
      return _richText(_normalSpan(text));
    }
    for (int i = 0; i < highlights.keys.toList().length; i++) {
      String? highlightedText = highlights.keys.toList()[i];

      if (highlightedText.isEmpty) {
        return _richText(_normalSpan(text));
      }
    }
    if (!caseSensitive) {
      highlights.forEach((key, value) {
        _modHighlights.putIfAbsent(key.toLowerCase(), () => value);
        _modHighlights.putIfAbsent(key.toUpperCase(), () => value);
      });
    } else {
      _modHighlights = Map.from(highlights);
    }
    //Main code
    List<TextSpan> _spans = [];
    int _start = 0;
    //For "No Case Sensitive" option
    String _lowerCaseText = text.toLowerCase();
    List<String> _lowerCaseHighlights = [];
    // List<String> _upperCaseHighlights = [];

    highlights.keys.toList().forEach((String element) {
      _lowerCaseHighlights.add(element.toLowerCase());
      // _upperCaseHighlights.add(element.toUpperCase());
    });

    while (true) {
      Map<int, String> _highlightsMap = Map(); //key (index), value (highlight).
      // Map<int, WordHighlight> _highlightsValueMap =
      //     Map(); //key (index), value (highlight).

      if (caseSensitive) {
        for (int i = 0; i < highlights.length; i++) {
          int _index = text.indexOf(highlights.keys.toList()[i], _start);
          if (_index >= 0) {
            _highlightsMap.putIfAbsent(
                _index, () => highlights.keys.toList()[i]);
            // _highlightsValueMap.putIfAbsent(
            //     _index, () => highlights.values.toList()[i]);
          }
        }
      } else {
        for (int i = 0; i < highlights.length; i++) {
          // create dict of upper and lower case vals
          // int _index =
          //     _upperCaseHighlights.indexOf(_upperCaseHighlights[i], _start);
          // if (_index >= 0) {
          //   _highlightsMap.putIfAbsent(
          //       _index, () => highlights.keys.toList()[i]);
          // }
          int _idx = _lowerCaseText.indexOf(_lowerCaseHighlights[i], _start);
          if (_idx >= 0) {
            _highlightsMap.putIfAbsent(_idx, () => highlights.keys.toList()[i]);
          }
        }
      }
      if (_highlightsMap.isNotEmpty) {
        List<int> _indexes = [];
        _highlightsMap.forEach((key, value) => _indexes.add(key));

        int _currentIndex = _indexes.reduce(min);
        String _currentHighlight = text.substring(_currentIndex,
            _currentIndex + _highlightsMap[_currentIndex]!.length);
        String _keyHighlightVal = _currentHighlight;

        if (!caseSensitive) {
          _keyHighlightVal = _keyHighlightVal.toLowerCase();
        }
        if (_currentIndex == _start) {
          _spans.add(_buildHighlightedBorderRadiusSpan(
              _currentHighlight, _modHighlights[_keyHighlightVal]!));

          _start += _currentHighlight.length;
        } else {
          // First check if the start char val has been passed
          if (_modHighlights[_keyHighlightVal]!.startChar != null) {
            // if start char is passed, only build highlight span if the start char matches the current index
            if (_currentIndex == _modHighlights[_keyHighlightVal]!.startChar) {
              _spans.add(_normalSpan(text.substring(_start, _currentIndex)));
              _spans.add(_buildHighlightedBorderRadiusSpan(
                  _currentHighlight, _modHighlights[_keyHighlightVal]!));
              _start = _currentIndex + _currentHighlight.length;
            } else {
              // build the normal span
              _spans.add(_normalSpan(text.substring(
                  _start, _currentIndex + _currentHighlight.length)));
              _start = _currentIndex + _currentHighlight.length;
            }
          } else {
            _spans.add(_normalSpan(text.substring(_start, _currentIndex)));
            _spans.add(_buildHighlightedBorderRadiusSpan(
                _currentHighlight, _modHighlights[_keyHighlightVal]!));
            _start = _currentIndex + _currentHighlight.length;
          }
        }
      } else {
        _spans.add(_normalSpan(text.substring(_start, text.length)));
        break;
      }
    }
    return _richText(TextSpan(children: _spans));
  }

  bool buildPaintBackground(
      BackgroundTextSpan backgroundTextSpan,
      Canvas canvas,
      Offset offset,
      TextPainter? painter,
      Rect rect,
      bool isLabelText,
      {Offset? endOffset,
      TextPainter? wholeTextPainter}) {
    final Rect textRect = offset & painter!.size;

    ///top-right
    if (endOffset != null) {
      final Rect firstLineRect =
          offset & Size(rect.right - offset.dx, painter.height);

      if (backgroundTextSpan.clipBorderRadius != null) {
        canvas.save();
        canvas.clipPath(Path()
          ..addRRect(backgroundTextSpan.clipBorderRadius!
              .resolve(painter.textDirection)
              .toRRect(firstLineRect)));
      }

      ///start
      canvas.drawRect(firstLineRect, backgroundTextSpan.background);

      if (backgroundTextSpan.clipBorderRadius != null) {
        canvas.restore();
      }

      ///endOffset.y has deviation,so we calculate with text height
      final int fullLinesAndLastLine =
          ((endOffset.dy - offset.dy) / painter.height).round();

      double y = offset.dy;
      for (int i = 0; i < fullLinesAndLastLine; i++) {
        y += painter.height;
        //last line
        if (i == fullLinesAndLastLine - 1) {
          final Rect lastLineRect =
              Offset(0.0, y) & Size(endOffset.dx, painter.height);
          if (backgroundTextSpan.clipBorderRadius != null) {
            canvas.save();
            canvas.clipPath(Path()
              ..addRRect(backgroundTextSpan.clipBorderRadius!
                  .resolve(painter.textDirection)
                  .toRRect(lastLineRect)));
          }
          canvas.drawRect(lastLineRect, backgroundTextSpan.background);
          if (backgroundTextSpan.clipBorderRadius != null) {
            canvas.restore();
          }
        }

        ///draw full line
        else {
          final Rect fullLineRect =
              Offset(0.0, y) & Size(rect.width, painter.height);

          if (backgroundTextSpan.clipBorderRadius != null) {
            canvas.save();
            canvas.clipPath(Path()
              ..addRRect(backgroundTextSpan.clipBorderRadius!
                  .resolve(painter.textDirection)
                  .toRRect(fullLineRect)));
          }

          ///draw full line
          canvas.drawRect(fullLineRect, backgroundTextSpan.background);

          if (backgroundTextSpan.clipBorderRadius != null) {
            canvas.restore();
          }
        }
      }
    } else {
      if (backgroundTextSpan.clipBorderRadius != null) {
        canvas.save();
        canvas.clipPath(Path()
          ..addRRect(backgroundTextSpan.clipBorderRadius!
              .resolve(painter.textDirection)
              .toRRect(textRect)));
      }

      canvas.drawRect(textRect, backgroundTextSpan.background);

      if (backgroundTextSpan.clipBorderRadius != null) {
        canvas.restore();
      }
    }

    ///remember return true to igore default background
    return true;
  }

  TextSpan _buildHighlightedBorderRadiusSpan(text, WordHighlight value) {
    return TextSpan(children: [
      BackgroundTextSpan(
          text: text,
          style: style.copyWith(
            height: 1.6,
            letterSpacing: 1.0,
            color: ThemeData.estimateBrightnessForColor(value.color) ==
                    Brightness.light
                ? Colors.black87
                : Colors.white,
          ),
          background: Paint()..color = value.color,
          clipBorderRadius: const BorderRadius.all(Radius.circular(3.0)),
          paintBackground: (BackgroundTextSpan backgroundTextSpan,
              Canvas canvas, Offset offset, TextPainter? painter, Rect rect,
              {Offset? endOffset, TextPainter? wholeTextPainter}) {
            return buildPaintBackground(
                backgroundTextSpan, canvas, offset, painter, rect, false,
                endOffset: endOffset, wholeTextPainter: wholeTextPainter);
          }),
      if (value.label != null)
        BackgroundTextSpan(
            text: "${value.label}",
            style: style.copyWith(
              fontSize: 10,
              color: ThemeData.estimateBrightnessForColor(value.color) ==
                      Brightness.light
                  ? Colors.black87
                  : Colors.white,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.15,
              height: 1.6,
              textBaseline: TextBaseline.ideographic,
              // color: value.color, //labelsDict![value.label]!,
              // backgroundColor: Colors.white,
            ),
            background: Paint()..color = value.color,
            clipBorderRadius: const BorderRadius.all(Radius.circular(3.0)),
            paintBackground: (BackgroundTextSpan backgroundTextSpan,
                Canvas canvas, Offset offset, TextPainter? painter, Rect rect,
                {Offset? endOffset, TextPainter? wholeTextPainter}) {
              return buildPaintBackground(
                  backgroundTextSpan, canvas, offset, painter, rect, false,
                  endOffset: endOffset, wholeTextPainter: wholeTextPainter);
            }),
      // TextSpan(
      //   text: " ${value.label} ",
      //   style: style.copyWith(
      //     fontSize: 10,
      //     fontWeight: FontWeight.bold,
      //     textBaseline: TextBaseline.ideographic,
      //     color: value.color, //labelsDict![value.label]!,
      //     backgroundColor: Colors.white,
      //   ),
      // ),
    ]);
  }

  TextSpan _normalSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style,
      );
    }
  }

  Text _richText(TextSpan text) {
    return ExtendedText.rich(
      text,
      key: Key(key.toString() + "-NEW"),
      textAlign: textAlign!,
      textDirection: textDirection,
      softWrap: softWrap!,
      overflow: overflow!,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis!,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
