import 'package:flutter/material.dart';

import 'utils.dart';

/// Responsive utility functions for converting pixel values to responsive sizes
/// Usage: 12.h(context) for responsive height, 24.w(context) for responsive width

// Reference screen dimensions (you can adjust these based on your design requirements)
const double _referenceWidth = 375.0; // Reference width (iPhone 6/7/8 width)
const double _referenceHeight = 812.0; // Reference height (iPhone X height)

extension ResponsiveExtensions on int {
  /// Converts pixel width to responsive width based on screen width
  double w(BuildContext context) {
    return this * (Utils.screenWidth(context) / _referenceWidth);
  }

  /// Converts pixel height to responsive height based on screen height
  double h(BuildContext context) {
    return this * (Utils.screenHeight(context) / _referenceHeight);
  }
}
