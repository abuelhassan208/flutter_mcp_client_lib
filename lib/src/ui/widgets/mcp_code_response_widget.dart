/// MCP Code Response Widget
///
/// This file defines a widget for displaying code-based MCP responses.
/// It handles code formatting, syntax highlighting, and provides options
/// for copying the code to the clipboard.
library mcp_code_response_widget;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';
import 'mcp_response_widget.dart';

/// Widget for displaying code-based MCP responses
///
/// This widget displays code-based MCP responses with proper formatting,
/// syntax highlighting, and options for copying the code to the clipboard.
class McpCodeResponseWidget extends McpResponseWidget {
  /// The code content to display
  final String codeContent;

  /// The programming language of the code
  final String? language;

  /// Whether to show line numbers
  final bool showLineNumbers;

  /// Whether to enable code selection
  final bool enableSelection;

  /// Whether to show a copy button
  final bool showCopyButton;

  /// Create a new MCP code response widget
  const McpCodeResponseWidget({
    super.key,
    required super.response,
    required super.theme,
    required this.codeContent,
    this.language,
    this.showLineNumbers = true,
    this.enableSelection = true,
    this.showCopyButton = true,
    super.onInteraction,
  });

  /// Create a widget from an MCP response
  ///
  /// This factory method creates a code response widget from an MCP response.
  /// It extracts the code content and language from the response result and
  /// creates a widget with the appropriate properties.
  factory McpCodeResponseWidget.fromResponse({
    Key? key,
    required McpResponse response,
    required McpTheme theme,
    required String codeKey,
    String? languageKey,
    bool showLineNumbers = true,
    bool enableSelection = true,
    bool showCopyButton = true,
    McpInteractionCallback? onInteraction,
  }) {
    // Extract the code content from the response result
    final codeContent = response.result?[codeKey] as String? ?? '';
    
    // Extract the language from the response result if a key is provided
    String? language;
    if (languageKey != null && response.result != null) {
      language = response.result![languageKey] as String?;
    }

    return McpCodeResponseWidget(
      key: key,
      response: response,
      theme: theme,
      codeContent: codeContent,
      language: language,
      showLineNumbers: showLineNumbers,
      enableSelection: enableSelection,
      showCopyButton: showCopyButton,
      onInteraction: onInteraction,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCodeHeader(context),
        const SizedBox(height: 8),
        _buildCodeContent(context),
      ],
    );
  }

  @override
  String getResponseType() {
    return 'Code Response';
  }

  /// Build the code header
  Widget _buildCodeHeader(BuildContext context) {
    return Row(
      children: [
        if (language != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              language!,
              style: theme.captionTextStyle.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Spacer(),
        if (showCopyButton)
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to clipboard',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codeContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
              triggerInteraction('copy', {'code': codeContent});
            },
          ),
      ],
    );
  }

  /// Build the code content
  Widget _buildCodeContent(BuildContext context) {
    // Split the code into lines for line numbering
    final lines = codeContent.split('\n');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.codeBackgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius / 2),
      ),
      child: showLineNumbers
          ? _buildCodeWithLineNumbers(context, lines)
          : _buildCodeWithoutLineNumbers(context),
    );
  }

  /// Build code with line numbers
  Widget _buildCodeWithLineNumbers(BuildContext context, List<String> lines) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            lines.length,
            (index) => Container(
              padding: const EdgeInsets.only(right: 8),
              height: 20,
              child: Text(
                '${index + 1}',
                style: theme.codeTextStyle.copyWith(
                  color: theme.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        // Vertical divider
        Container(
          width: 1,
          height: lines.length * 20,
          color: theme.borderColor.withOpacity(0.5),
          margin: const EdgeInsets.only(right: 8),
        ),
        // Code content
        Expanded(
          child: enableSelection
              ? SelectableText(
                  codeContent,
                  style: theme.codeTextStyle.copyWith(
                    color: theme.codeTextColor,
                  ),
                )
              : Text(
                  codeContent,
                  style: theme.codeTextStyle.copyWith(
                    color: theme.codeTextColor,
                  ),
                ),
        ),
      ],
    );
  }

  /// Build code without line numbers
  Widget _buildCodeWithoutLineNumbers(BuildContext context) {
    return enableSelection
        ? SelectableText(
            codeContent,
            style: theme.codeTextStyle.copyWith(
              color: theme.codeTextColor,
            ),
          )
        : Text(
            codeContent,
            style: theme.codeTextStyle.copyWith(
              color: theme.codeTextColor,
            ),
          );
  }
}
