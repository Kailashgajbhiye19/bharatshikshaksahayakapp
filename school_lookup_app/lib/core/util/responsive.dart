import 'package:flutter/material.dart';

/// [Responsive] utility class to handle different screen sizes.
/// In production, use this to adapt UI for Tablets, Foldables, and Phones.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({super.key, required this.mobile, this.tablet, this.desktop});

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= 600 && MediaQuery.sizeOf(context).width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1200;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1200 && desktop != null) return desktop!;
    if (width >= 600 && tablet != null) return tablet!;
    return mobile;
  }
}
