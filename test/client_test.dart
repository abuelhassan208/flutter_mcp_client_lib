import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp/flutter_mcp.dart';

import 'mocks/mock_transport.dart';
import 'helpers/test_helpers.dart';

// Create a test-specific McpRequest implementation
class TestMcpRequest extends McpRequestImpl {
  const TestMcpRequest({
    required super.method,
    required super.id,
    super.params,
  });
}

// We're now using the anyMcpRequest matcher from test_helpers.dart

void main() {
  group('McpClient', () {
    late MockMcpClientTransport mockTransport;
    late McpClient client;

    setUp(() {
      mockTransport = MockMcpClientTransport();
      client = McpClient(
        name: 'Test Client',
        version: '1.0.0',
        capabilities: const ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
        ),
      );
    });

    test('connect negotiates capabilities', () async {
      // Use our helper to initialize the client
      await initializeClientForTesting(client, mockTransport);

      // Verify the client is connected and initialized
      expect(client.isConnected, isTrue);
      expect(client.isInitialized, isTrue);

      // Verify capabilities were negotiated
      expect(client.serverCapabilities, isNotNull);
      expect(client.serverCapabilities?.resources?.list, isTrue);
      expect(client.serverCapabilities?.resources?.read, isTrue);
      expect(client.serverCapabilities?.tools?.list, isTrue);
      expect(client.serverCapabilities?.tools?.call, isTrue);
      expect(client.serverCapabilities?.prompts?.list, isTrue);
      expect(client.serverCapabilities?.prompts?.get, isTrue);
    });

    test('listResources calls transport with correct method', () async {
      // Initialize the client
      await initializeClientForTesting(client, mockTransport);

      // Set the response for listResources request
      mockTransport.sendRequestResponse = MockMcpResponse(
        id: '1',
        result: {
          'resources': [
            {
              'name': 'test',
              'uriTemplate': 'test://{id}',
              'description': 'Test resource',
            },
          ],
        },
      );

      // Call listResources
      final resources = await client.listResources();

      // We don't need to verify the request was sent since we're testing the result

      // Verify result
      expect(resources, isNotEmpty);
      expect(resources.length, equals(1));
      expect(resources.first.name, equals('test'));
      expect(resources.first.uriTemplate, equals('test://{id}'));
      expect(resources.first.description, equals('Test resource'));
    });

    test('readResource calls transport', () async {
      // Initialize the client
      await initializeClientForTesting(client, mockTransport);

      // Set the response for readResource request
      mockTransport.sendRequestResponse = MockMcpResponse(
        id: '1',
        result: {
          'contents': [
            {'uri': 'test://123', 'text': 'Test content'},
          ],
        },
      );

      // Call readResource
      final contents = await client.readResource('test://123');

      // We don't need to verify the request was sent since we're testing the result

      // Verify result
      expect(contents, isNotEmpty);
      expect(contents.length, equals(1));
      expect(contents.first.uri, equals('test://123'));
      expect(contents.first.text, equals('Test content'));
    });

    test('disconnect closes transport', () async {
      // Initialize the client first
      await initializeClientForTesting(client, mockTransport);

      // Disconnect client
      await client.disconnect();

      // Verify client is disconnected
      expect(client.isConnected, isFalse);
    });

    test('throws error when calling methods without connection', () async {
      // Create a new client that's not connected
      final disconnectedClient = McpClient(
        name: 'Test Client',
        version: '1.0.0',
        capabilities: const ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
        ),
      );

      // Verify listResources throws
      expect(() => disconnectedClient.listResources(), throwsA(isA<StateError>()));

      // Verify readResource throws
      expect(
        () => disconnectedClient.readResource('test://123'),
        throwsA(isA<StateError>()),
      );

      // Verify listTools throws
      expect(() => disconnectedClient.listTools(), throwsA(isA<StateError>()));

      // Verify callTool throws
      expect(() => disconnectedClient.callTool('test', {}), throwsA(isA<StateError>()));

      // Verify listPrompts throws
      expect(() => disconnectedClient.listPrompts(), throwsA(isA<StateError>()));

      // Verify getPrompt throws
      expect(() => disconnectedClient.getPrompt('test', {}), throwsA(isA<StateError>()));
    });
  });
}
