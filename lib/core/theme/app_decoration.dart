import 'package:flutter/material.dart';

class AppDecoration {
  static BoxShadow commonShadow = BoxShadow(
    offset: const Offset(0, 1),
    blurRadius: 2,
    color: Colors.black.withValues(alpha: 0.05),
  );
}
