import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp/flutter_mcp.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import the MessageRole enum
import 'package:flutter_mcp/src/models/mcp_prompts.dart';

import 'mock_transport_test.mocks.dart';

/// Helper class to create McpResponse objects for testing
class TestMcpResponse implements McpResponse {
  @override
  final String id;

  @override
  final Map<String, dynamic>? result;

  @override
  final McpError? error;

  @override
  final String jsonrpc = '2.0';

  @override
  bool get isSuccess => error == null;

  @override
  bool get stringify => true;

  TestMcpResponse({
    required this.id,
    this.result,
    this.error,
  });

  /// Create a response from a JSON object
  static TestMcpResponse fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final result = json['result'] as Map<String, dynamic>?;
    final errorJson = json['error'] as Map<String, dynamic>?;

    McpError? error;
    if (errorJson != null) {
      error = McpError(
        code: errorJson['code'] as int,
        message: errorJson['message'] as String,
        data: errorJson['data'],
      );
    }

    return TestMcpResponse(
      id: id,
      result: result,
      error: error,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'jsonrpc': jsonrpc,
      'id': id,
    };

    if (isSuccess) {
      json['result'] = result;
    } else {
      json['error'] = error?.toJson();
    }

    return json;
  }

  @override
  List<Object?> get props => [jsonrpc, id, result, error];
}

@GenerateMocks([McpClientTransport])
void main() {
  group('McpClient with mocked transport', () {
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

      // Set up default behavior for the mock transport
      when(mockTransport.isConnected).thenReturn(true);
      when(mockTransport.serverCapabilities).thenReturn(
        ServerCapabilities(
          resources: ResourceCapabilityConfig(list: true, read: true),
          tools: ToolCapabilityConfig(list: true, call: true),
          prompts: PromptCapabilityConfig(list: true, get: true),
        ),
      );
      when(mockTransport.connect()).thenAnswer((_) async {});
      when(mockTransport.disconnect()).thenAnswer((_) async {});
      when(mockTransport.requests).thenAnswer((_) => Stream.empty());
      when(mockTransport.notifications).thenAnswer((_) => Stream.empty());

      // Set up a default response for the initialize request
      when(mockTransport.sendRequest(any)).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        if (request.method == 'initialize') {
          return TestMcpResponse.fromJson({
            'jsonrpc': '2.0',
            'id': request.id,
            'result': {
              'capabilities': {
                'resources': {'list': true, 'read': true},
                'tools': {'list': true, 'call': true},
                'prompts': {'list': true, 'get': true},
              },
              'protocolVersion': mcpProtocolVersion,
              'serverInfo': {'name': 'Mock Server', 'version': '1.0.0'},
            },
          });
        }
        throw Exception('Unexpected request: ${request.method}');
      });
    });

    test('client can connect to server and negotiate capabilities', () async {
      await client.connect(mockTransport);

      expect(client.isConnected, isTrue);
      expect(client.serverCapabilities, isNotNull);

      // Verify server capabilities
      final capabilities = client.serverCapabilities!;
      expect(capabilities.resources?.list, isTrue);
      expect(capabilities.resources?.read, isTrue);
      expect(capabilities.tools?.list, isTrue);
      expect(capabilities.tools?.call, isTrue);
      expect(capabilities.prompts?.list, isTrue);
      expect(capabilities.prompts?.get, isTrue);

      verify(mockTransport.connect()).called(1);
    });

    test('client can list resources', () async {
      // Set up the mock to return a response for listResources
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'listResources'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'resources': [
              {
                'name': 'test',
                'uriTemplate': 'test://{id}',
                'description': 'Test resource',
              },
              {
                'name': 'greeting',
                'uriTemplate': 'greeting://{name}',
                'description': 'Greeting resource',
              },
            ],
          },
        });
      });

      await client.connect(mockTransport);
      final resources = await client.listResources();

      expect(resources, isNotEmpty);
      expect(resources.length, equals(2));
      expect(resources[0].name, equals('test'));
      expect(resources[0].uriTemplate, equals('test://{id}'));
      expect(resources[0].description, equals('Test resource'));
      expect(resources[1].name, equals('greeting'));
      expect(resources[1].uriTemplate, equals('greeting://{name}'));
      expect(resources[1].description, equals('Greeting resource'));

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client can read resources', () async {
      // Set up the mock to return a response for readResource
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'readResource'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'contents': [
              {
                'uri': 'test://123',
                'text': 'Test content for ID: 123',
              },
            ],
          },
        });
      });

      await client.connect(mockTransport);
      final contents = await client.readResource('test://123');

      expect(contents, isNotEmpty);
      expect(contents.length, equals(1));
      expect(contents[0].uri, equals('test://123'));
      expect(contents[0].text, equals('Test content for ID: 123'));

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client can list tools', () async {
      // Set up the mock to return a response for listTools
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'listTools'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'tools': [
              {
                'name': 'add',
                'description': 'Add two numbers',
                'arguments': [
                  {
                    'name': 'a',
                    'description': 'First number',
                    'required': true,
                  },
                  {
                    'name': 'b',
                    'description': 'Second number',
                    'required': true,
                  },
                ],
              },
            ],
          },
        });
      });

      await client.connect(mockTransport);
      final tools = await client.listTools();

      expect(tools, isNotEmpty);
      expect(tools.length, equals(1));
      expect(tools[0].name, equals('add'));
      expect(tools[0].description, equals('Add two numbers'));
      expect(tools[0].arguments.length, equals(2));
      expect(tools[0].arguments[0].name, equals('a'));
      expect(tools[0].arguments[0].required, isTrue);
      expect(tools[0].arguments[1].name, equals('b'));
      expect(tools[0].arguments[1].required, isTrue);

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client can call tools', () async {
      // Set up the mock to return a response for callTool
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'callTool'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'content': [
              {
                'type': 'text',
                'text': '12',
              },
            ],
            'isError': false,
          },
        });
      });

      await client.connect(mockTransport);
      final result = await client.callTool('add', {'a': '5', 'b': '7'});

      expect(result, isNotNull);
      expect(result.content, isNotEmpty);
      expect(result.content.length, equals(1));
      expect(result.content[0].type, equals(ContentType.text));
      expect(result.content[0].text, equals('12'));

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client can list prompts', () async {
      // Set up the mock to return a response for listPrompts
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'listPrompts'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'prompts': [
              {
                'name': 'greeting',
                'description': 'A greeting prompt',
                'arguments': [
                  {
                    'name': 'name',
                    'description': 'Name to greet',
                    'required': true,
                  },
                ],
              },
            ],
          },
        });
      });

      await client.connect(mockTransport);
      final prompts = await client.listPrompts();

      expect(prompts, isNotEmpty);
      expect(prompts.length, equals(1));
      expect(prompts[0].name, equals('greeting'));
      expect(prompts[0].description, equals('A greeting prompt'));
      expect(prompts[0].arguments.length, equals(1));
      expect(prompts[0].arguments[0].name, equals('name'));
      expect(prompts[0].arguments[0].required, isTrue);

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client can get prompts', () async {
      // Set up the mock to return a response for getPrompt
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'getPrompt'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'result': {
            'messages': [
              {
                'role': 'system',
                'content': {'type': 'text', 'text': 'You are a helpful assistant.'},
              },
              {
                'role': 'user',
                'content': {'type': 'text', 'text': 'Hello, John!'},
              },
            ],
          },
        });
      });

      await client.connect(mockTransport);
      final result = await client.getPrompt('greeting', {'name': 'John'});

      expect(result, isNotNull);
      expect(result.messages, isNotEmpty);
      expect(result.messages.length, equals(2));
      expect(result.messages[0].role, equals(MessageRole.system));
      expect(result.messages[0].content.text, equals('You are a helpful assistant.'));
      expect(result.messages[1].role, equals(MessageRole.user));
      expect(result.messages[1].content.text, equals('Hello, John!'));

      // Verify that sendRequest was called at least once (for initialization and the actual request)
      verify(mockTransport.sendRequest(any)).called(greaterThanOrEqualTo(1));
    });

    test('client handles errors correctly', () async {
      // Set up the mock to return error responses for nonexistent resources
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'readResource' && request.params?['uri'] == 'nonexistent://123'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'error': {
            'code': -33000,
            'message': 'Resource not found',
          },
        });
      });

      // Set up the mock to return error responses for nonexistent tools
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'callTool' && request.params?['name'] == 'nonexistent'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'error': {
            'code': -33001,
            'message': 'Tool not found',
          },
        });
      });

      // Set up the mock to return error responses for nonexistent prompts
      when(mockTransport.sendRequest(argThat(predicate<McpRequest>((request) =>
        request.method == 'getPrompt' && request.params?['name'] == 'nonexistent'
      )))).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as McpRequest;
        return TestMcpResponse.fromJson({
          'jsonrpc': '2.0',
          'id': request.id,
          'error': {
            'code': -33002,
            'message': 'Prompt not found',
          },
        });
      });

      await client.connect(mockTransport);

      // Test resource not found error
      expect(
        () => client.readResource('nonexistent://123'),
        throwsA(
          predicate<McpError>(
            (error) => error.code == -33000 && error.message == 'Resource not found',
          ),
        ),
      );

      // Test tool not found error
      expect(
        () => client.callTool('nonexistent', {}),
        throwsA(
          predicate<McpError>(
            (error) => error.code == -33001 && error.message == 'Tool not found',
          ),
        ),
      );

      // Test prompt not found error
      expect(
        () => client.getPrompt('nonexistent', {}),
        throwsA(
          predicate<McpError>(
            (error) => error.code == -33002 && error.message == 'Prompt not found',
          ),
        ),
      );
    });
  });
}
