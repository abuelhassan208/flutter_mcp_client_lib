import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp_client_lib/flutter_mcp.dart';

void main() {
  group('MCP UI Widgets', () {
    testWidgets('McpTextResponseWidget displays text content', (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'text-response-1',
        result: {
          'text': 'This is a test text response',
        },
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                return McpTextResponseWidget.fromResponse(
                  response: response,
                  theme: theme,
                  textKey: 'text',
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget displays the text
      expect(find.text('This is a test text response'), findsOneWidget);
      expect(find.text('Text Response'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('McpCodeResponseWidget displays code content', (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'code-response-1',
        result: {
          'code': 'print("Hello, World!");',
          'language': 'dart',
        },
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                return McpCodeResponseWidget.fromResponse(
                  response: response,
                  theme: theme,
                  codeKey: 'code',
                  languageKey: 'language',
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget displays the code
      expect(find.text('print("Hello, World!");'), findsOneWidget);
      expect(find.text('Code Response'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('McpDataResponseWidget displays data content', (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'data-response-1',
        result: {
          'data': {
            'name': 'Test Data',
            'value': 42,
          },
        },
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                return McpDataResponseWidget.fromResponse(
                  response: response,
                  theme: theme,
                  dataKey: 'data',
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget displays the data
      expect(find.text('Data Response'), findsOneWidget);
      expect(find.text('name'), findsOneWidget);
      expect(find.text('"Test Data"'), findsOneWidget);
      expect(find.text('value'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('McpErrorResponseWidget displays error content', (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'error-response-1',
        error: McpError(
          code: -32700,
          message: 'Parse error',
          data: {'line': 10, 'column': 5},
        ),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                return McpErrorResponseWidget(
                  response: response,
                  theme: theme,
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget displays the error
      expect(find.text('Error -32700'), findsOneWidget);
      expect(find.text('Parse error'), findsOneWidget);

      // The current implementation uses a different label for error details
      expect(find.text('{line: 10, column: 5}'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('McpResponseRenderer renders the appropriate widget for text response',
        (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'text-response-1',
        result: {
          'text': 'This is a test text response',
        },
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                final renderer = McpResponseRenderer(theme: theme);
                return renderer.render(context, response);
              },
            ),
          ),
        ),
      );

      // Verify the renderer chose the text response widget
      expect(find.text('This is a test text response'), findsOneWidget);
      expect(find.text('Text Response'), findsOneWidget);
    });

    testWidgets('McpResponseRenderer renders the appropriate widget for code response',
        (WidgetTester tester) async {
      // Create a mock response
      final response = McpResponseImpl(
        id: 'code-response-1',
        result: {
          'code': 'print("Hello, World!");',
          'language': 'dart',
        },
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = McpTheme.light(context);
                final renderer = McpResponseRenderer(theme: theme);
                return renderer.render(context, response);
              },
            ),
          ),
        ),
      );

      // Verify the renderer chose the code response widget
      expect(find.text('print("Hello, World!");'), findsOneWidget);
      expect(find.text('Code Response'), findsOneWidget);
    });
  });
}
