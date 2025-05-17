/// MCP Client UI Extensions
///
/// This file defines extension methods for the McpClient class to easily
/// render responses and integrate with the UI.
library mcp_client_ui_extensions;

import 'package:flutter/material.dart';

import '../../client/mcp_client.dart';
import '../../models/models.dart';
import '../renderers/mcp_response_renderer.dart';
import '../themes/mcp_theme.dart';
import '../widgets/mcp_response_widget.dart';

/// Extension methods for [McpClient] to easily render responses
extension McpClientUiExtensions on McpClient {
  /// Render a resource response
  ///
  /// This method reads a resource and renders it with the appropriate widget.
  Future<Widget> renderResource(
    BuildContext context,
    String uri, {
    McpTheme? theme,
    McpInteractionCallback? onInteraction,
  }) async {
    final actualTheme = theme ?? McpTheme.fromTheme(context);
    final renderer = McpResponseRenderer(
      theme: actualTheme,
      onInteraction: onInteraction,
    );

    try {
      final result = await readResource(uri);

      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create a response object from the result
      final response = McpResponseImpl(
        id: 'resource-${Uri.encodeComponent(uri)}',
        result: {'text': result.first.text, 'uri': uri},
      );
      return renderer.render(context, response);
    } catch (e) {
      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create an error response
      final response = McpResponseImpl(
        id: 'resource-${Uri.encodeComponent(uri)}',
        error:
            e is McpError
                ? e
                : McpError(code: -1, message: 'Failed to read resource: $e'),
      );
      return renderer.render(context, response);
    }
  }

  /// Render a tool response
  ///
  /// This method calls a tool and renders the result with the appropriate widget.
  Future<Widget> renderToolCall(
    BuildContext context,
    String name,
    Map<String, dynamic> arguments, {
    McpTheme? theme,
    McpInteractionCallback? onInteraction,
  }) async {
    final actualTheme = theme ?? McpTheme.fromTheme(context);
    final renderer = McpResponseRenderer(
      theme: actualTheme,
      onInteraction: onInteraction,
    );

    try {
      final result = await callTool(name, arguments);

      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create a response object from the result
      final response = McpResponseImpl(
        id: 'tool-$name',
        result: {
          'data': {
            'content':
                result.content
                    .map(
                      (c) => {
                        'type': c.type.toString().split('.').last,
                        'text': c.text,
                      },
                    )
                    .toList(),
            'isError': result.isError,
          },
          'tool': name,
          'arguments': arguments,
        },
      );
      return renderer.render(context, response);
    } catch (e) {
      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create an error response
      final response = McpResponseImpl(
        id: 'tool-$name',
        error:
            e is McpError
                ? e
                : McpError(code: -1, message: 'Failed to call tool: $e'),
      );
      return renderer.render(context, response);
    }
  }

  /// Render a prompt response
  ///
  /// This method gets a prompt and renders it with the appropriate widget.
  Future<Widget> renderPrompt(
    BuildContext context,
    String name,
    Map<String, dynamic> arguments, {
    McpTheme? theme,
    McpInteractionCallback? onInteraction,
  }) async {
    final actualTheme = theme ?? McpTheme.fromTheme(context);
    final renderer = McpResponseRenderer(
      theme: actualTheme,
      onInteraction: onInteraction,
    );

    try {
      final result = await getPrompt(name, arguments);

      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create a response object from the result
      final response = McpResponseImpl(
        id: 'prompt-$name',
        result: {
          'text': result.messages
              .map((m) => '${m.role}: ${m.content.text}')
              .join('\n\n'),
          'prompt': name,
          'arguments': arguments,
        },
      );
      return renderer.render(context, response);
    } catch (e) {
      // Check if the context is still valid
      if (!context.mounted) {
        throw StateError('Context is no longer valid');
      }

      // Create an error response
      final response = McpResponseImpl(
        id: 'prompt-$name',
        error:
            e is McpError
                ? e
                : McpError(code: -1, message: 'Failed to get prompt: $e'),
      );
      return renderer.render(context, response);
    }
  }

  /// Create a stream of widgets for real-time response rendering
  ///
  /// This method creates a stream of widgets that update as responses
  /// are received. It can be used with StreamBuilder for real-time UI updates.
  ///
  /// IMPORTANT: This method should be used with a StreamBuilder that handles
  /// the context.mounted check, as we cannot do that in a stream transformation.
  /// Example:
  /// ```dart
  /// StreamBuilder<Widget>(
  ///   stream: client.createResponseStream(context, responseStream),
  ///   builder: (context, snapshot) {
  ///     if (!context.mounted) return const SizedBox();
  ///     if (snapshot.hasData) {
  ///       return snapshot.data!;
  ///     }
  ///     return const CircularProgressIndicator();
  ///   },
  /// )
  /// ```
  Stream<Widget> createResponseStream(
    BuildContext context,
    Stream<McpResponse> responseStream, {
    McpTheme? theme,
    McpInteractionCallback? onInteraction,
  }) {
    // Capture the theme at creation time to avoid BuildContext issues
    final actualTheme = theme ?? McpTheme.fromTheme(context);
    final renderer = McpResponseRenderer(
      theme: actualTheme,
      onInteraction: onInteraction,
    );

    // We need to check if the context is still mounted before rendering
    // Since we can't do that in a stream transformation, the caller must
    // handle this in their StreamBuilder
    return responseStream.map((response) {
      // Note: The caller must ensure the context is still valid when using this stream
      // ignore: use_build_context_synchronously
      return renderer.render(context, response);
    });
  }
}
