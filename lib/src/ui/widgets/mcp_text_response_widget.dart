/// MCP Text Response Widget
///
/// This file defines a widget for displaying text-based MCP responses.
/// It handles plain text formatting and provides options for styling.
library mcp_text_response_widget;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';
import 'mcp_response_widget.dart';

/// Widget for displaying text-based MCP responses
///
/// This widget displays text-based MCP responses with proper formatting
/// and styling. It supports plain text and provides options for copying
/// the text to the clipboard.
class McpTextResponseWidget extends McpResponseWidget {
  /// The text content to display
  final String textContent;

  /// Whether to enable text selection
  final bool enableSelection;

  /// Whether to show a copy button
  final bool showCopyButton;

  /// Whether to enable markdown rendering
  final bool enableMarkdown;

  /// Create a new MCP text response widget
  const McpTextResponseWidget({
    super.key,
    required super.response,
    required super.theme,
    required this.textContent,
    this.enableSelection = true,
    this.showCopyButton = true,
    this.enableMarkdown = false,
    super.onInteraction,
  });

  /// Create a widget from an MCP response
  ///
  /// This factory method creates a text response widget from an MCP response.
  /// It extracts the text content from the response result and creates a widget
  /// with the appropriate properties.
  factory McpTextResponseWidget.fromResponse({
    Key? key,
    required McpResponse response,
    required McpTheme theme,
    required String textKey,
    bool enableSelection = true,
    bool showCopyButton = true,
    bool enableMarkdown = false,
    McpInteractionCallback? onInteraction,
  }) {
    // Extract the text content from the response result
    final textContent = response.result?[textKey] as String? ?? '';

    return McpTextResponseWidget(
      key: key,
      response: response,
      theme: theme,
      textContent: textContent,
      enableSelection: enableSelection,
      showCopyButton: showCopyButton,
      enableMarkdown: enableMarkdown,
      onInteraction: onInteraction,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCopyButton) _buildCopyButton(context),
        const SizedBox(height: 8),
        _buildTextContent(context),
      ],
    );
  }

  @override
  String getResponseType() {
    return 'Text Response';
  }

  /// Build the copy button
  Widget _buildCopyButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.copy),
        tooltip: 'Copy to clipboard',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: textContent));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
          triggerInteraction('copy', {'text': textContent});
        },
      ),
    );
  }

  /// Build the text content
  Widget _buildTextContent(BuildContext context) {
    final textWidget = enableSelection
        ? SelectableText(
            textContent,
            style: theme.bodyTextStyle,
          )
        : Text(
            textContent,
            style: theme.bodyTextStyle,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius / 2),
        border: Border.all(color: theme.borderColor.withOpacity(0.5)),
      ),
      child: textWidget,
    );
  }
}
