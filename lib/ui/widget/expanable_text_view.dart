import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plastichero_app/constants/color_theme.dart';
import 'package:plastichero_app/constants/setting.dart';

class ExpandableTextView extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final String moreText;
  final TextStyle? moreTextStyle;
  final String foldText;
  final bool isFoldText;
  final int trimLines;

  const ExpandableTextView({
    Key? key,
    required this.text,
    this.textStyle = const TextStyle(
      fontSize: 14.0,
      color: Color(ColorTheme.defaultText),
      fontFamily: Setting.appFont,
      fontWeight: FontWeight.w400,
    ),
    required this.moreText,
    this.moreTextStyle = const TextStyle(
      color: Color(ColorTheme.c_999999),
      fontSize: 13.0,
      fontFamily: Setting.appFont,
      fontWeight: FontWeight.w400,
    ),
    required this.foldText,
    this.isFoldText = true,
    this.trimLines = 2,
  }) : super(key: key);

  @override
  State<ExpandableTextView> createState() => _ExpandableTextViewState();
}

class _ExpandableTextViewState extends State<ExpandableTextView> {
  bool readMore = true;

  @override
  Widget build(BuildContext context) {
    TextSpan link = TextSpan(
      text: readMore
          ? ' .. ${widget.moreText}'
          : widget.isFoldText
              ? ' .. ${widget.foldText}'
              : '',
      style: widget.moreTextStyle,
      recognizer: TapGestureRecognizer()..onTap = onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl, // better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );

        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);

        final linkSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);

        final textSize = textPainter.size;

        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(
          Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ),
        );
        endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        bool isNewLine = false;

        if (endIndex >= 0 && endIndex < widget.text.length && widget.text.substring(endIndex, endIndex + 1) == '\n') {
          isNewLine = true;
        }

        TextSpan textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: readMore
                ? isNewLine
                    ? '${widget.text.substring(0, endIndex)}\n'
                    : widget.text.substring(0, endIndex)
                : widget.text,
            style: widget.textStyle,
            children: <TextSpan>[link],
          );
          return RichText(
            softWrap: true,
            overflow: TextOverflow.clip,
            text: textSpan,
          );
        } else {
          return Text(
            widget.text,
            style: widget.textStyle,
          );
        }
      },
    );

    return result;
  }

  void onTapLink() {
    setState(() {
      readMore = !readMore;
    });
  }
}
