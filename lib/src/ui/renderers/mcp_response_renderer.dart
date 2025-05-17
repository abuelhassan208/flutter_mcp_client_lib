/// MCP Response Renderer
///
/// This file defines a renderer for MCP responses that can automatically
/// detect and render the appropriate widget for a given response.
library;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';
import '../widgets/mcp_code_response_widget.dart';
import '../widgets/mcp_data_response_widget.dart';
import '../widgets/mcp_error_response_widget.dart';
import '../widgets/mcp_response_widget.dart';
import '../widgets/mcp_text_response_widget.dart';

/// A renderer for MCP responses
///
/// This class provides methods for rendering MCP responses with the
/// appropriate widget based on the response type.
class McpResponseRenderer {
  /// The theme to use for styling
  final McpTheme theme;

  /// Callback for interaction events
  final McpInteractionCallback? onInteraction;

  /// Create a new MCP response renderer
  const McpResponseRenderer({required this.theme, this.onInteraction});

  /// Render an MCP response
  ///
  /// This method automatically detects the response type and renders
  /// the appropriate widget.
  Widget render(BuildContext context, McpResponse response) {
    // If the response has an error, render an error widget
    if (response.error != null) {
      return McpErrorResponseWidget(
        response: response,
        theme: theme,
        onInteraction: onInteraction,
      );
    }

    // If the response has no result, return a loading widget
    if (response.result == null) {
      return _buildLoadingWidget(context);
    }

    // Detect the response type and render the appropriate widget
    final responseType = _detectResponseType(response);
    switch (responseType) {
      case McpResponseType.text:
        return McpTextResponseWidget.fromResponse(
          response: response,
          theme: theme,
          textKey: 'text',
          onInteraction: onInteraction,
        );
      case McpResponseType.code:
        return McpCodeResponseWidget.fromResponse(
          response: response,
          theme: theme,
          codeKey: 'code',
          languageKey: 'language',
          onInteraction: onInteraction,
        );
      case McpResponseType.data:
        return McpDataResponseWidget.fromResponse(
          response: response,
          theme: theme,
          dataKey: 'data',
          onInteraction: onInteraction,
        );
      case McpResponseType.unknown:
        // If we can't detect the type, try to render as data
        return McpDataResponseWidget(
          response: response,
          theme: theme,
          data: response.result!,
          onInteraction: onInteraction,
        );
    }
  }

  /// Detect the type of an MCP response
  ///
  /// This method examines the response result to determine the most
  /// appropriate widget type for rendering.
  McpResponseType _detectResponseType(McpResponse response) {
    final result = response.result;
    if (result == null) {
      return McpResponseType.unknown;
    }

    // Check for text response
    if (result.containsKey('text') && result['text'] is String) {
      return McpResponseType.text;
    }

    // Check for code response
    if (result.containsKey('code') && result['code'] is String) {
      return McpResponseType.code;
    }

    // Check for data response
    if (result.containsKey('data') && result['data'] is Map) {
      return McpResponseType.data;
    }

    // If we can't determine the type, return unknown
    return McpResponseType.unknown;
  }

  /// Build a loading widget
  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      margin: theme.margin,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Loading Response', style: theme.headerTextStyle),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

/// Types of MCP responses
enum McpResponseType {
  /// A text response
  text,

  /// A code response
  code,

  /// A data response
  data,

  /// An unknown response type
  unknown,
}
