/// MCP Theme
///
/// This file defines the theme structure for MCP UI components.
/// It provides customizable properties for colors, typography, spacing, and animations.
library;

import 'package:flutter/material.dart';

/// A theme for MCP UI components
///
/// This class provides customizable properties for colors, typography, spacing, and animations
/// used by MCP UI components. It integrates with Flutter's theme system and provides
/// light and dark theme variants.
class McpTheme {
  /// The primary color used for headers, buttons, and other primary UI elements
  final Color primaryColor;

  /// The secondary color used for accents and highlights
  final Color secondaryColor;

  /// The background color for MCP components
  final Color backgroundColor;

  /// The color for text on the background
  final Color textColor;

  /// The color for secondary text (subtitles, captions)
  final Color secondaryTextColor;

  /// The color for error messages and indicators
  final Color errorColor;

  /// The color for success messages and indicators
  final Color successColor;

  /// The color for warning messages and indicators
  final Color warningColor;

  /// The color for information messages and indicators
  final Color infoColor;

  /// The color for code blocks background
  final Color codeBackgroundColor;

  /// The color for code text
  final Color codeTextColor;

  /// The color for borders
  final Color borderColor;

  /// The radius for rounded corners
  final double borderRadius;

  /// The default padding for MCP components
  final EdgeInsets padding;

  /// The default margin for MCP components
  final EdgeInsets margin;

  /// The text style for headers
  final TextStyle headerTextStyle;

  /// The text style for body text
  final TextStyle bodyTextStyle;

  /// The text style for code
  final TextStyle codeTextStyle;

  /// The text style for captions and small text
  final TextStyle captionTextStyle;

  /// The duration for animations
  final Duration animationDuration;

  /// The curve for animations
  final Curve animationCurve;

  /// Create a new MCP theme
  const McpTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.codeBackgroundColor,
    required this.codeTextColor,
    required this.borderColor,
    required this.borderRadius,
    required this.padding,
    required this.margin,
    required this.headerTextStyle,
    required this.bodyTextStyle,
    required this.codeTextStyle,
    required this.captionTextStyle,
    required this.animationDuration,
    required this.animationCurve,
  });

  /// Create a light theme
  factory McpTheme.light(BuildContext context) {
    final theme = Theme.of(context);
    return McpTheme(
      primaryColor: theme.colorScheme.primary,
      secondaryColor: theme.colorScheme.secondary,
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.onSurface,
      secondaryTextColor: theme.colorScheme.onSurface.withAlpha(
        153,
      ), // 0.6 opacity
      errorColor: theme.colorScheme.error,
      successColor: Colors.green,
      warningColor: Colors.orange,
      infoColor: Colors.blue,
      codeBackgroundColor: Colors.grey[100]!,
      codeTextColor: Colors.black87,
      borderColor: Colors.grey[300]!,
      borderRadius: 8.0,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      headerTextStyle: theme.textTheme.titleLarge!,
      bodyTextStyle: theme.textTheme.bodyMedium!,
      codeTextStyle: theme.textTheme.bodyMedium!.copyWith(
        fontFamily: 'monospace',
        fontSize: 14.0,
      ),
      captionTextStyle: theme.textTheme.bodySmall!,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
    );
  }

  /// Create a dark theme
  factory McpTheme.dark(BuildContext context) {
    final theme = Theme.of(context);
    return McpTheme(
      primaryColor: theme.colorScheme.primary,
      secondaryColor: theme.colorScheme.secondary,
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.onSurface,
      secondaryTextColor: theme.colorScheme.onSurface.withAlpha(
        153,
      ), // 0.6 opacity
      errorColor: theme.colorScheme.error,
      successColor: Colors.green[400]!,
      warningColor: Colors.orange[300]!,
      infoColor: Colors.blue[300]!,
      codeBackgroundColor: Colors.grey[850]!,
      codeTextColor: Colors.white,
      borderColor: Colors.grey[700]!,
      borderRadius: 8.0,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      headerTextStyle: theme.textTheme.titleLarge!,
      bodyTextStyle: theme.textTheme.bodyMedium!,
      codeTextStyle: theme.textTheme.bodyMedium!.copyWith(
        fontFamily: 'monospace',
        fontSize: 14.0,
      ),
      captionTextStyle: theme.textTheme.bodySmall!,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
    );
  }

  /// Create a theme from the current Flutter theme
  factory McpTheme.fromTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? McpTheme.light(context)
        : McpTheme.dark(context);
  }

  /// Create a copy of this theme with some properties replaced
  McpTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? secondaryTextColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? codeBackgroundColor,
    Color? codeTextColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    TextStyle? headerTextStyle,
    TextStyle? bodyTextStyle,
    TextStyle? codeTextStyle,
    TextStyle? captionTextStyle,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return McpTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
      codeTextColor: codeTextColor ?? this.codeTextColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      codeTextStyle: codeTextStyle ?? this.codeTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}

/// Extension methods for [BuildContext] to easily access the MCP theme
extension McpThemeExtension on BuildContext {
  /// Get the MCP theme from the current Flutter theme
  McpTheme get mcpTheme => McpTheme.fromTheme(this);
}
