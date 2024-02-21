import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plastichero_app/util/debug.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import 'crop_render.dart';
import 'matrix_decomposition.dart';

/// Used for cropping the [child] widget.
class Crop extends StatefulWidget {
  final Widget child;
  final GlobalKey childKey;
  final CropController controller;
  final Color backgroundColor;
  final Color dimColor;
  final EdgeInsetsGeometry padding;
  final Widget? background;
  final Widget? foreground;
  final Widget? helper;
  final Widget? overlay;
  final bool interactive;
  final BoxShape shape;
  final ValueChanged<MatrixDecomposition>? onChanged;
  final Duration animationDuration;
  final Offset offset;
  final double scale;

  const Crop({
    Key? key,
    required this.child,
    required this.childKey,
    required this.controller,
    this.padding = const EdgeInsets.all(8),
    this.dimColor = const Color.fromRGBO(0, 0, 0, 0.8),
    this.backgroundColor = Colors.transparent,
    this.background,
    this.foreground,
    this.helper,
    this.overlay,
    this.interactive = true,
    this.shape = BoxShape.rectangle,
    this.onChanged,
    this.animationDuration = const Duration(milliseconds: 200),
    this.offset = Offset.zero,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CropState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(ColorProperty('dimColor', dimColor));
    properties.add(DiagnosticsProperty('child', child));
    properties.add(DiagnosticsProperty('controller', controller));
    properties.add(DiagnosticsProperty('background', background));
    properties.add(DiagnosticsProperty('foreground', foreground));
    properties.add(DiagnosticsProperty('helper', helper));
    properties.add(DiagnosticsProperty('overlay', overlay));
    properties.add(FlagProperty('interactive', value: interactive, ifTrue: 'enabled', ifFalse: 'disabled', showName: true));
  }
}

class CropState extends State<Crop> with TickerProviderStateMixin {
  final tag = 'CropState';

  final _key = GlobalKey();
  final _parent = GlobalKey();
  final _repaintBoundaryKey = GlobalKey();

  final _fitKey = GlobalKey();

  double _previousScale = 1;
  Offset _previousOffset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _endOffset = Offset.zero;

  // double _previousGestureRotation = 0.0;

  /// Store the pointer count (finger involved to perform scaling).
  ///
  /// This is used to compare with the value in
  /// [ScaleUpdateDetails.pointerCount]. Check [_onScaleUpdate] for detail.
  int _previousPointerCount = 0;

  late AnimationController _controller;
  late CurvedAnimation _animation;

  Future<ui.Image> _crop(double pixelRatio) {
    final rrb = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    return rrb.toImage(pixelRatio: pixelRatio);
  }

  @override
  void initState() {
    widget.controller._cropCallback = _crop;
    widget.controller.addListener(_reCenterImage);

    _startOffset = widget.offset;
    _endOffset = widget.offset;
    _previousOffset = widget.offset;
    _previousScale = widget.scale;
    widget.controller._offset = widget.offset;
    widget.controller._scale = widget.scale;

    //Setup animation.
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = CurvedAnimation(curve: Curves.easeInOut, parent: _controller);
    _animation.addListener(() {
      if (_animation.isCompleted) {
        _reCenterImage(false);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Crop oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  void _reCenterImage([bool animate = true]) {
    if (_previousPointerCount > 0) {
      return;
    }

    final viewSize = _key.currentContext!.size!;
    final imageSize = widget.childKey.currentContext!.size!;

    final scale = widget.controller._scale * widget.controller._getMinScale();

    final viewW = viewSize.width;
    final viewH = viewSize.height;

    final imageW = imageSize.width;
    final imageH = imageSize.height;

    if (viewW == 0 || viewH == 0) {
      Debug.log(tag, '## View size is empty !!');
      return;
    }

    if (imageW <= 0 || imageH <= 0) {
      Debug.log(tag, '## Image size is empty !!');
      return;
    }

    double width = 0;
    double height = 0;
    double moveX = 0;
    double moveY = 0;

    final offset = _toVector2(widget.controller._offset);
    double offsetX = offset.x;
    double offsetY = offset.y;

    if (imageW > imageH) {
      // When the image width is bigger, the height standard
      height = viewH * scale;
      width = (viewH / imageH) * imageW * scale;
    } else {
      // When the image height is bigger, the width standard
      width = viewW * scale;
      height = (viewW / imageW) * imageH * scale;
    }

    double boundary = 0;
    final boundaryX = (width - viewW) / 2;
    final boundaryY = (height - viewH) / 2;

    _startOffset = widget.controller._offset;
    _endOffset = widget.controller._offset;

    // Set the width boundary
    if (boundaryX == 0) {
      moveX -= offsetX;
    } else {
      if (offsetX > 0) {
        boundary = boundaryX - offsetX;
        if (boundary < 0) {
          moveX = boundary;
        }
      } else if (offsetX < 0) {
        boundary = -(boundaryX + offsetX);
        if (boundary > 0) {
          moveX = boundary;
        }
      }
    }

    // Set the height boundary
    if (boundaryY == 0) {
      moveY -= offsetY;
    } else {
      if (offsetY > 0) {
        boundary = boundaryY - offsetY;
        if (boundary < 0) {
          moveY = boundary;
        }
      } else if (offsetY < 0) {
        boundary = -(boundaryY + offsetY);
        if (boundary > 0) {
          moveY = boundary;
        }
      }
    }

    _endOffset += Offset(moveX, moveY);

    widget.controller._offset = _endOffset;

    if (animate) {
      if (_controller.isCompleted || _controller.isAnimating) {
        _controller.reset();
      }
      _controller.forward();
    } else {
      _startOffset = _endOffset;
    }

    setState(() {});
    _handleOnChanged();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    widget.controller._offset += details.focalPoint - _previousOffset;
    _previousOffset = details.focalPoint;
    widget.controller._scale = _previousScale * details.scale;
    if (widget.controller._scale < 0.8) {
      widget.controller._scale = 0.8;
    }
    _startOffset = widget.controller._offset;
    _endOffset = widget.controller._offset;

    // In the case where lesser than 2 fingers involved in scaling, we ignore
    // the rotation handling.
    if (details.pointerCount > 1) {
      // In the first touch, we reset all the values.
      if (_previousPointerCount != details.pointerCount) {
        _previousPointerCount = details.pointerCount;
        // _previousGestureRotation = 0.0;
      }

      /*
      // Instead of directly embracing the details.rotation, we need to
      // perform calculation to ensure that each round of rotation is smooth.
      // A user rotate the image using finger and release is considered as a
      // round. Without this calculation, the rotation degree of the image will
      // be reset.
      final gestureRotation = vm.degrees(details.rotation);

      // Within a round of rotation, the details.rotation is provided with
      // incremented value when user rotates. We don't need this, all we
      // want is the offset.
      final gestureRotationOffset = _previousGestureRotation - gestureRotation;

      // Remove the offset and constraint the degree scope to 0° <= degree <=
      // 360°. Constraint the scope is unnecessary, however, by doing this,
      // it would make our life easier when debugging.
      final rotationAfterCalculation =
          (widget.controller.rotation - gestureRotationOffset) % 360;

      */ /* details.rotation is in radians, convert this to degrees and set
        our rotation */ /*
      widget.controller._rotation = rotationAfterCalculation;
      _previousGestureRotation = gestureRotation;
      */
    }

    setState(() {});
    _handleOnChanged();
  }

  void _handleOnChanged() {
    widget.onChanged?.call(MatrixDecomposition(scale: widget.controller.scale, rotation: widget.controller.rotation, translation: widget.controller.offset));
  }

  void setCropInfo(Offset offset, double scale) {
    widget.controller.removeListener(_reCenterImage);
    _startOffset = offset;
    _endOffset = offset;
    widget.controller.setOffsetAndScale(offset, scale);
    widget.controller.addListener(_reCenterImage);
  }

  @override
  Widget build(BuildContext context) {
    // final r = vm.radians(widget.controller._rotation);
    final s = widget.controller._scale * widget.controller._getMinScale();
    final o = Offset.lerp(_startOffset, _endOffset, _animation.value)!;

    Widget _buildInnerCanvas() {
      final ip = IgnorePointer(
        key: _key,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(o.dx, o.dy, 0)
            // ..rotateZ(r)
            ..scale(s, s, 1),
          child: FittedBox(
            key: _fitKey,
            fit: BoxFit.cover,
            child: widget.child,
          ),
        ),
      );

      List<Widget> widgets = [];

      if (widget.background != null) {
        widgets.add(widget.background!);
      }

      widgets.add(ip);

      if (widget.foreground != null) {
        widgets.add(widget.foreground!);
      }

      if (widgets.length == 1) {
        return ip;
      } else {
        return Stack(
          fit: StackFit.expand,
          children: widgets,
        );
      }
    }

    Widget _buildRepaintBoundary() {
      final repaint = RepaintBoundary(
        key: _repaintBoundaryKey,
        child: _buildInnerCanvas(),
      );

      if (widget.helper == null) {
        return repaint;
      }

      return Stack(
        fit: StackFit.expand,
        children: [repaint, widget.helper!],
      );
    }

    final gd = GestureDetector(
      onScaleStart: (details) {
        _previousOffset = details.focalPoint;
        _previousScale = max(widget.controller._scale, 1);
      },
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: (details) {
        widget.controller._scale = min(2, max(widget.controller._scale, 1));
        _previousPointerCount = 0;
        _reCenterImage();
      },
    );

    List<Widget> over = [
      CropRenderObjectWidget(
        aspectRatio: widget.controller._aspectRatio,
        backgroundColor: widget.backgroundColor,
        shape: widget.shape,
        dimColor: widget.dimColor,
        child: _buildRepaintBoundary(),
      ),
    ];

    if (widget.overlay != null) {
      over.add(widget.overlay!);
    }

    if (widget.interactive) {
      over.add(gd);
    }

    return ClipRect(
      key: _parent,
      child: Stack(
        fit: StackFit.expand,
        children: over,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.controller.removeListener(_reCenterImage);
    super.dispose();
  }
}

typedef _CropCallback = Future<ui.Image> Function(double pixelRatio);

/// The controller used to control the rotation, scale and actual cropping.
class CropController extends ChangeNotifier {
  double _aspectRatio = 1;
  double _rotation = 0;
  double _scale = 1;
  double _minScale = 1;
  Offset _offset = Offset.zero;
  _CropCallback? _cropCallback;

  /// Gets the current aspect ratio.
  double get aspectRatio => _aspectRatio;

  /// Sets the desired aspect ratio.
  set aspectRatio(double value) {
    _aspectRatio = value;
    notifyListeners();
  }

  /// Gets the current scale.
  double get scale => max(_scale, 1);

  /// Sets the desired scale.
  set scale(double value) {
    _scale = max(value, 1);
    notifyListeners();
  }

  /// Gets the current rotation.
  double get rotation => _rotation;

  /// Sets the desired rotation.
  set rotation(double value) {
    _rotation = value;
    notifyListeners();
  }

  /// Gets the current offset.
  Offset get offset => _offset;

  /// Sets the desired offset.
  set offset(Offset value) {
    _offset = value;
    notifyListeners();
  }

  void setOffsetAndScale(Offset offset, double scale) {
    _offset = offset;
    _scale = scale;
    notifyListeners();
  }

  /// Gets the transformation matrix.
  Matrix4 get transform => Matrix4.identity()
    ..translate(_offset.dx, _offset.dy, 0)
    ..rotateZ(_rotation)
    ..scale(_scale, _scale, 1);

  /// Constructor
  CropController({
    double aspectRatio = 1.0,
    double scale = 1.0,
    double rotation = 0,
  }) {
    _aspectRatio = aspectRatio;
    _scale = scale;
    _rotation = rotation;
  }

  double _getMinScale() {
    return _minScale;
  }

  /// Capture an image of the current state of this widget and its children.
  ///
  /// The returned [ui.Image] has uncompressed raw RGBA bytes, will have
  /// dimensions equal to the size of the [child] widget multiplied by [pixelRatio].
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [window.devicePixelRatio] for the device, so specifying 1.0 (the default)
  /// will give you a 1:1 mapping between logical pixels and the output pixels
  /// in the image.
  Future<ui.Image?> crop({double pixelRatio = 1}) {
    if (_cropCallback == null) {
      return Future.value(null);
    }

    return _cropCallback!.call(pixelRatio);
  }
}

vm.Vector2 _toVector2(Offset offset) => vm.Vector2(offset.dx, offset.dy);
