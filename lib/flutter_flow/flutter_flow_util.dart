import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// FlutterFlow core utilities (minimal but compatible)
/// ---------------------------------------------------------------------------

/// Model creator used by FlutterFlow pages
T createModel<T>(BuildContext context, T Function() builder) {
  return builder();
}

/// ---------------------------------------------------------------------------
/// TextStyle extension used by FlutterFlow (.override)
/// ---------------------------------------------------------------------------
extension FlutterFlowTextStyleExtension on TextStyle {
  TextStyle override({
    TextStyle? font, // ✅ REQUIRED for FlutterFlow
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    final base = font != null ? merge(font) : this;

    return base.copyWith(
      fontFamily: fontFamily ?? base.fontFamily,
      color: color ?? base.color,
      fontSize: fontSize ?? base.fontSize,
      fontWeight: fontWeight ?? base.fontWeight,
      fontStyle: fontStyle ?? base.fontStyle,
      letterSpacing: letterSpacing ?? base.letterSpacing,
      height: height ?? base.height,
      decoration: decoration ?? base.decoration,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Widget list helpers used by FlutterFlow
/// ---------------------------------------------------------------------------
extension FlutterFlowWidgetListExtensions on List<Widget> {
  /// Inserts a widget between each item
  List<Widget> divide(Widget divider) {
    final widgets = <Widget>[];
    for (var i = 0; i < length; i++) {
      widgets.add(this[i]);
      if (i < length - 1) {
        widgets.add(divider);
      }
    }
    return widgets;
  }

  /// Adds a widget to the beginning of the list
  List<Widget> addToStart(Widget widget) {
    return [widget, ...this];
  }

  /// Adds a widget to the end of the list
  List<Widget> addToEnd(Widget widget) {
    return [...this, widget];
  }
}

/// ---------------------------------------------------------------------------
/// Optional context helpers
/// ---------------------------------------------------------------------------
extension FlutterFlowBuildContextExtensions on BuildContext {
  bool get isDarkMode =>
      Theme.of(this).brightness == Brightness.dark;

  Size get screenSize => MediaQuery.of(this).size;
}
