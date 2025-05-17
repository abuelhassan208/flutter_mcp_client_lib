/// MCP Error Response Widget
///
/// This file defines a widget for displaying error MCP responses.
/// It handles error formatting and provides options for error details.
library mcp_error_response_widget;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';
import 'mcp_response_widget.dart';

/// Widget for displaying error MCP responses
///
/// This widget displays error MCP responses with proper formatting
/// and styling. It provides options for showing error details and
/// handling different error types.
class McpErrorResponseWidget extends McpResponseWidget {
  /// Whether to show error details
  final bool showDetails;

  /// Whether to show a retry button
  final bool showRetryButton;

  /// Callback for retry button
  final VoidCallback? onRetry;

  /// Create a new MCP error response widget
  const McpErrorResponseWidget({
    super.key,
    required super.response,
    required super.theme,
    this.showDetails = true,
    this.showRetryButton = false,
    this.onRetry,
    super.onInteraction,
  }) : assert(
          !showRetryButton || onRetry != null,
          'onRetry must be provided if showRetryButton is true',
        );

  @override
  Widget buildContent(BuildContext context) {
    final error = response.error;
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildErrorHeader(context, error),
        const SizedBox(height: 8),
        _buildErrorMessage(context, error),
        if (showDetails && error.data != null) ...[
          const SizedBox(height: 8),
          _buildErrorDetails(context, error),
        ],
        if (showRetryButton) ...[
          const SizedBox(height: 16),
          _buildRetryButton(context),
        ],
      ],
    );
  }

  @override
  String getResponseType() {
    return 'Error Response';
  }

  /// Build the error header
  Widget _buildErrorHeader(BuildContext context, McpError error) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: theme.errorColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Error ${error.code}',
          style: theme.headerTextStyle.copyWith(
            color: theme.errorColor,
          ),
        ),
      ],
    );
  }

  /// Build the error message
  Widget _buildErrorMessage(BuildContext context, McpError error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(theme.borderRadius / 2),
        border: Border.all(color: theme.errorColor.withOpacity(0.3)),
      ),
      child: Text(
        error.message,
        style: theme.bodyTextStyle.copyWith(
          color: theme.textColor,
        ),
      ),
    );
  }

  /// Build the error details
  Widget _buildErrorDetails(BuildContext context, McpError error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Error Details:',
          style: theme.captionTextStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.codeBackgroundColor,
            borderRadius: BorderRadius.circular(theme.borderRadius / 2),
          ),
          child: SelectableText(
            error.data.toString(),
            style: theme.codeTextStyle.copyWith(
              color: theme.codeTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the retry button
  Widget _buildRetryButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          onRetry?.call();
          triggerInteraction('retry', {'error_code': response.error!.code});
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.backgroundColor,
          backgroundColor: theme.primaryColor,
        ),
      ),
    );
  }
}
