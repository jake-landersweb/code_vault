import 'package:flutter/material.dart';

class WizardItem {
  final String title;
  final IconData icon;
  final Widget child;

  WizardItem({
    required this.title,
    required this.icon,
    required this.child,
  });
}

class WizardModel extends ChangeNotifier {
  late int _index;
  late int numPages;
  late PageController controller;
  late Duration duration;
  late Curve curve;

  WizardModel({
    required this.numPages,
    int initialPage = 0,
    required this.duration,
    required this.curve,
  }) {
    controller = PageController(initialPage: initialPage);
    setIndex(initialPage);
  }

  /// get the current index
  int getPage() {
    return _index;
  }

  /// set the current index
  void setIndex(index) {
    _index = index;
    notifyListeners();
  }

  /// set the current page
  void setPage(int index) {
    controller.animateToPage(
      index,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// navigate to the next page
  void nextPage() {
    controller.nextPage(
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// navigate to the previous page
  void previousPage() {
    controller.previousPage(
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// whether the user is at the end of the wizard or not
  bool isAtEnd() {
    return _index == numPages - 1;
  }
}
