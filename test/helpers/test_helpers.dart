import 'package:flutter_mcp_client_lib/flutter_mcp.dart';
import '../mocks/mock_transport.dart';

/// Create a test McpRequest for use in tests
class TestMcpRequest extends McpRequestImpl {
  const TestMcpRequest({
    required super.method,
    required super.id,
    super.params,
  });
}

/// Helper function to initialize a client for testing without using reflection
Future<void> initializeClientForTesting(
  McpClient client,
  MockMcpClientTransport mockTransport,
) async {
  // Setup server capabilities
  final serverCapabilities = ServerCapabilities(
    resources: ResourceCapabilityConfig(list: true, read: true),
    tools: ToolCapabilityConfig(list: true, call: true),
    prompts: PromptCapabilityConfig(list: true, get: true),
  );

  // Setup the mock transport
  mockTransport.setServerCapabilities(serverCapabilities);

  // Override the sendRequest method to return the initialization response
  // We're not using when() here because we've overridden the method in the mock class
  mockTransport.sendRequestResponse = MockMcpResponse(
    id: '1',
    result: {
      'capabilities': {
        'resources': {'list': true, 'read': true},
        'tools': {'list': true, 'call': true},
        'prompts': {'list': true, 'get': true},
      },
      'protocolVersion': mcpProtocolVersion,
      'serverInfo': {'name': 'Test Server', 'version': '1.0.0'},
    },
  );

  // Connect and initialize the client
  await client.connect(mockTransport);
}
