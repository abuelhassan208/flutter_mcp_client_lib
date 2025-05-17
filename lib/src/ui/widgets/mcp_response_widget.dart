/// MCP Response Widget
///
/// This file defines the base widget for displaying MCP responses.
/// It provides a common structure for all response types and handles
/// error cases and response validation.
library;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';

/// Callback for interaction events with MCP response widgets
typedef McpInteractionCallback =
    void Function(
      String responseId,
      String interactionType,
      Map<String, dynamic> data,
    );

/// Base widget for displaying MCP responses
///
/// This abstract class provides a common structure for all MCP response widgets.
/// It handles error cases and response validation, and provides utility methods
/// for subclasses.
abstract class McpResponseWidget extends StatelessWidget {
  /// The MCP response to display
  final McpResponse response;

  /// The theme to use for styling
  final McpTheme theme;

  /// Callback for interaction events
  final McpInteractionCallback? onInteraction;

  /// Create a new MCP response widget
  const McpResponseWidget({
    super.key,
    required this.response,
    required this.theme,
    this.onInteraction,
  });

  /// Build the content of the response widget
  ///
  /// This method must be implemented by subclasses to build the specific
  /// content for the response type.
  @protected
  Widget buildContent(BuildContext context);

  /// Get the type of the response
  ///
  /// This method must be implemented by subclasses to return a string
  /// identifying the response type.
  @protected
  String getResponseType();

  @override
  Widget build(BuildContext context) {
    // If the response has an error, display an error widget
    if (response.error != null) {
      return _buildErrorWidget(context);
    }

    // If the response has no result, display a loading widget
    if (response.result == null) {
      return _buildLoadingWidget(context);
    }

    // Build the content widget
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
          _buildHeader(context),
          const SizedBox(height: 8),
          buildContent(context),
        ],
      ),
    );
  }

  /// Build the header for the response widget
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(getResponseType(), style: theme.headerTextStyle),
        const Spacer(),
        Text('ID: ${response.id}', style: theme.captionTextStyle),
      ],
    );
  }

  /// Build an error widget for the response
  Widget _buildErrorWidget(BuildContext context) {
    final error = response.error!;
    return Container(
      margin: theme.margin,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.errorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: theme.errorColor),
              const SizedBox(width: 8),
              Text(
                'Error ${error.code}',
                style: theme.headerTextStyle.copyWith(color: theme.errorColor),
              ),
              const Spacer(),
              Text('ID: ${response.id}', style: theme.captionTextStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(error.message, style: theme.bodyTextStyle),
          if (error.data != null) ...[
            const SizedBox(height: 8),
            Text('Additional data:', style: theme.captionTextStyle),
            const SizedBox(height: 4),
            Text(error.data.toString(), style: theme.codeTextStyle),
          ],
        ],
      ),
    );
  }

  /// Build a loading widget for the response
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
          Row(
            children: [
              Text('Loading', style: theme.headerTextStyle),
              const Spacer(),
              Text('ID: ${response.id}', style: theme.captionTextStyle),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Trigger an interaction event
  ///
  /// This method can be called by subclasses to trigger an interaction event.
  /// It calls the [onInteraction] callback if it is provided.
  @protected
  void triggerInteraction(String interactionType, Map<String, dynamic> data) {
    onInteraction?.call(response.id, interactionType, data);
  }

  /// Get a value from the response result
  ///
  /// This method can be used by subclasses to safely get values from the
  /// response result. It returns null if the result is null or if the key
  /// does not exist.
  @protected
  T? getResultValue<T>(String key) {
    if (response.result == null) {
      return null;
    }
    final value = response.result![key];
    if (value is T) {
      return value;
    }
    return null;
  }

  /// Check if the response result contains a key
  ///
  /// This method can be used by subclasses to check if the response result
  /// contains a specific key.
  @protected
  bool hasResultKey(String key) {
    if (response.result == null) {
      return false;
    }
    return response.result!.containsKey(key);
  }
}
