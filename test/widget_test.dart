// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp_client_lib/flutter_mcp.dart';

void main() {
  test('McpClient can be instantiated', () {
    final client = McpClient(
      name: 'Test Client',
      version: '1.0.0',
      capabilities: const ClientCapabilities(
        sampling: SamplingCapabilityConfig(sample: true),
      ),
    );

    expect(client, isNotNull);
  });
}
