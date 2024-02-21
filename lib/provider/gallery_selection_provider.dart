import 'package:flutter/material.dart';
import 'package:plastichero_app/notifier/gallery_selection_notifier.dart';

class GallerySelectionProvider extends InheritedWidget {
  final GallerySelectionNotifier notifier;

  const GallerySelectionProvider({
    Key? key,
    required Widget child,
    required this.notifier,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(GallerySelectionProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
