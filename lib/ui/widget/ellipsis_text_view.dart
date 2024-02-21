import 'package:flutter/material.dart';

import '../../constants/color_theme.dart';
import '../../constants/setting.dart';

class EllipsisTextView extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int lastTextNum;
  final String cutText;

  const EllipsisTextView({
    Key? key,
    required this.text,
    this.lastTextNum = 4,
    this.cutText = '...',
    this.style = const TextStyle(
      fontSize: 13,
      fontFamily: Setting.appFont,
      fontWeight: FontWeight.w400,
      color: Color(ColorTheme.defaultText),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final result = getExceededCharacters(textPainter, text, style, constraints.maxWidth);

        return Text(
          result,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
    );
  }

  String getExceededCharacters(TextPainter textPainter, String text, TextStyle style, double maxWidth) {
    if (lastTextNum <= 0 || text.length < lastTextNum + cutText.length) {
      return text;
    }

    String result = '';
    double minTextWidth = 0;
    String tailText = '';
    TextSpan span;
    TextPainter spanTextPainter;

    /// minTextWidth
    span = TextSpan(
      text: '1',
      style: style,
    );
    spanTextPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    spanTextPainter.layout(maxWidth: maxWidth);
    minTextWidth = spanTextPainter.width;

    for (int i = 0; i < text.length; i++) {
      span = TextSpan(
        text: text.substring(0, i + 1),
        style: style,
      );
      spanTextPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      spanTextPainter.layout(maxWidth: maxWidth + minTextWidth);

      if (spanTextPainter.width > textPainter.width) {
        tailText = '$cutText${text.substring(text.length - lastTextNum, text.length)}';

        for (int i = text.length; i >= 0; i--) {
          int end = text.length - lastTextNum - (text.length - i);
          if (end < 0) {
            return text;
          }
          result = '${text.substring(0, end)}$tailText';

          span = TextSpan(
            text: result,
            style: style,
          );
          spanTextPainter = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
          );
          spanTextPainter.layout(maxWidth: maxWidth + (minTextWidth * lastTextNum));

          if (spanTextPainter.width - textPainter.width <= 0) {
            break;
          }
        }
        break;
      }
    }

    if (result.isEmpty) {
      result = text;
    }
    return result;
  }
}
