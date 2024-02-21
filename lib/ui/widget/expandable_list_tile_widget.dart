import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ExpandableListTile extends StatelessWidget {
  ExpandableListTile({Key? key, required this.title, this.trailingImage, required this.expanded, required this.onExpandPressed, required this.child, this.trailingAddWidget}) : super(key: key);
  late Widget title;
  Widget? trailingImage;
  late bool expanded;
  late Widget child;
  late VoidCallback onExpandPressed;
  Widget? trailingAddWidget;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      if (trailingImage != null) ...{
        ListTile(
          title: title,
          onTap: onExpandPressed,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (trailingAddWidget != null) ...{trailingAddWidget!},
              RotatableSection(rotated: expanded, child: trailingImage!),
            ],
          ),
        ),
      } else ...{
        ListTile(
          title: title,
          onTap: onExpandPressed,
        ),
      },
      ExpandableSection(
        expand: expanded,
        child: child,
      )
    ]);
  }
}

class ExpandableSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  const ExpandableSection({Key? key, this.expand = false, required this.child}) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> sizeAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    sizeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
    opacityAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.slowMiddle,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: opacityAnimation, child: SizeTransition(axisAlignment: 1.0, sizeFactor: sizeAnimation, child: widget.child));
  }
}

class RotatableSection extends StatefulWidget {
  final Widget child;
  final bool rotated;
  final double initialSpin;
  final double endingSpin;

  const RotatableSection({Key? key, this.rotated = false, required this.child, this.initialSpin = 0, this.endingSpin = 0.5}) : super(key: key);

  @override
  State<RotatableSection> createState() => _RotatableSectionState();
}

class _RotatableSectionState extends State<RotatableSection> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runCheck();
  }

  final double _oneSpin = 6.283184;

  void prepareAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: _oneSpin * widget.initialSpin,
      upperBound: _oneSpin * widget.endingSpin,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    );
  }

  void _runCheck() {
    if (widget.rotated) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(RotatableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runCheck();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, widget) {
        return Transform.rotate(
          angle: animationController.value,
          child: widget,
        );
      },
    );
  }
}
