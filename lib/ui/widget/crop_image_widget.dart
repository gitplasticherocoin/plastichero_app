import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plastichero_app/util/crop/crop_render.dart';

class CropImageWidget extends StatefulWidget {
  final double scale;
  final Offset offset;
  final Widget child;
  final Color? backgroundColor;

  const CropImageWidget({
    Key? key,
    // required this.cropKey,
    this.scale = 1.0,
    this.offset = Offset.zero,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CropImageWidgetState();
  }
}

class CropImageWidgetState extends State<CropImageWidget> {
  final String tag = 'CropWidget';

  final _repaintBoundaryKey = GlobalKey();

  final double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildInnerCanvas() {
      final ip = IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(widget.offset.dx, widget.offset.dy, 0)
            // ..rotateZ(r)
            ..scale(widget.scale, widget.scale, 1),
          child: FittedBox(
            fit: BoxFit.cover,
            child: widget.child,
          ),
        ),
      );
      return ip;
    }

    Widget _buildRepaintBoundary() {
      final repaint = RepaintBoundary(
        key: _repaintBoundaryKey,
        child: _buildInnerCanvas(),
      );

      return repaint;
    }

    return ClipRect(
      child: CropRenderObjectWidget(
        aspectRatio: _aspectRatio,
        backgroundColor: widget.backgroundColor ?? const Color(0xffdddddd),
        shape: BoxShape.rectangle,
        // dimColor: widget.dimColor,
        child: _buildRepaintBoundary(),
      ),
    );
  }

  Future<ui.Image> crop(double pixelRatio) {
    final rrb = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    return rrb.toImage(pixelRatio: pixelRatio);
  }
}
