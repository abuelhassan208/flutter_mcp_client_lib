import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp/flutter_mcp.dart';

void main() {
  group('MCP Models', () {
    group('McpError', () {
      test('can be instantiated with required fields', () {
        final error = McpError(
          code: -32700,
          message: 'Parse error',
        );

        expect(error.code, equals(-32700));
        expect(error.message, equals('Parse error'));
        expect(error.data, isNull);
      });

      test('can be instantiated with all fields', () {
        final error = McpError(
          code: -32700,
          message: 'Parse error',
          data: {'line': 10, 'column': 5},
        );

        expect(error.code, equals(-32700));
        expect(error.message, equals('Parse error'));
        expect(error.data, isNotNull);
        // Use null-safe access for data fields
        expect(error.data?['line'], equals(10));
        expect(error.data?['column'], equals(5));
      });

      test('can be serialized to JSON', () {
        final error = McpError(
          code: -32700,
          message: 'Parse error',
          data: {'line': 10, 'column': 5},
        );

        final json = error.toJson();

        expect(json['code'], equals(-32700));
        expect(json['message'], equals('Parse error'));
        expect(json['data'], isNotNull);
        expect(json['data']['line'], equals(10));
        expect(json['data']['column'], equals(5));
      });

      test('can be deserialized from JSON', () {
        final json = {
          'code': -32700,
          'message': 'Parse error',
          'data': {'line': 10, 'column': 5},
        };

        final error = McpError.fromJson(json);

        expect(error.code, equals(-32700));
        expect(error.message, equals('Parse error'));
        expect(error.data, isNotNull);
        // Use null-safe access for data fields
        expect(error.data?['line'], equals(10));
        expect(error.data?['column'], equals(5));
      });
    });

    group('ResourceInfo', () {
      test('can be instantiated with required fields', () {
        final resourceInfo = ResourceInfo(
          name: 'test',
          uriTemplate: 'test://{id}',
        );

        expect(resourceInfo.name, equals('test'));
        expect(resourceInfo.uriTemplate, equals('test://{id}'));
        expect(resourceInfo.description, isNull);
      });

      test('can be instantiated with all fields', () {
        final resourceInfo = ResourceInfo(
          name: 'test',
          uriTemplate: 'test://{id}',
          description: 'Test resource',
        );

        expect(resourceInfo.name, equals('test'));
        expect(resourceInfo.uriTemplate, equals('test://{id}'));
        expect(resourceInfo.description, equals('Test resource'));
      });

      test('can be serialized to JSON', () {
        final resourceInfo = ResourceInfo(
          name: 'test',
          uriTemplate: 'test://{id}',
          description: 'Test resource',
        );

        final json = resourceInfo.toJson();

        expect(json['name'], equals('test'));
        expect(json['uriTemplate'], equals('test://{id}'));
        expect(json['description'], equals('Test resource'));
      });

      test('can be deserialized from JSON', () {
        final json = {
          'name': 'test',
          'uriTemplate': 'test://{id}',
          'description': 'Test resource',
        };

        final resourceInfo = ResourceInfo.fromJson(json);

        expect(resourceInfo.name, equals('test'));
        expect(resourceInfo.uriTemplate, equals('test://{id}'));
        expect(resourceInfo.description, equals('Test resource'));
      });
    });

    group('ResourceContent', () {
      test('can be instantiated with required fields', () {
        final resourceContent = ResourceContent(
          uri: 'test://123',
          text: 'Test content',
        );

        expect(resourceContent.uri, equals('test://123'));
        expect(resourceContent.text, equals('Test content'));
        expect(resourceContent.mimeType, isNull);
      });

      test('can be instantiated with all fields', () {
        final resourceContent = ResourceContent(
          uri: 'test://123',
          text: 'Test content',
          mimeType: 'text/plain',
        );

        expect(resourceContent.uri, equals('test://123'));
        expect(resourceContent.text, equals('Test content'));
        expect(resourceContent.mimeType, equals('text/plain'));
      });

      test('can be serialized to JSON', () {
        final resourceContent = ResourceContent(
          uri: 'test://123',
          text: 'Test content',
          mimeType: 'text/plain',
        );

        final json = resourceContent.toJson();

        expect(json['uri'], equals('test://123'));
        expect(json['text'], equals('Test content'));
        expect(json['mimeType'], equals('text/plain'));
      });

      test('can be deserialized from JSON', () {
        final json = {
          'uri': 'test://123',
          'text': 'Test content',
          'mimeType': 'text/plain',
        };

        final resourceContent = ResourceContent.fromJson(json);

        expect(resourceContent.uri, equals('test://123'));
        expect(resourceContent.text, equals('Test content'));
        expect(resourceContent.mimeType, equals('text/plain'));
      });
    });

    group('ClientCapabilities', () {
      test('can be instantiated with default values', () {
        final capabilities = ClientCapabilities();

        // All fields are nullable, so we need to check if they're null first
        expect(capabilities.sampling, isNull);
        expect(capabilities.resources, isNull);
        expect(capabilities.tools, isNull);
        expect(capabilities.prompts, isNull);
      });

      test('can be instantiated with custom values', () {
        final capabilities = ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
          resources: ResourceCapabilityConfig(list: true, read: true),
          tools: ToolCapabilityConfig(list: true, call: true),
          prompts: PromptCapabilityConfig(list: true, get: true),
        );

        // Check that all fields are not null and have the expected values
        expect(capabilities.sampling, isNotNull);
        expect(capabilities.sampling?.sample, isTrue);

        expect(capabilities.resources, isNotNull);
        expect(capabilities.resources?.list, isTrue);
        expect(capabilities.resources?.read, isTrue);

        expect(capabilities.tools, isNotNull);
        expect(capabilities.tools?.list, isTrue);
        expect(capabilities.tools?.call, isTrue);

        expect(capabilities.prompts, isNotNull);
        expect(capabilities.prompts?.list, isTrue);
        expect(capabilities.prompts?.get, isTrue);
      });

      test('can be serialized to JSON', () {
        final capabilities = ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
          resources: ResourceCapabilityConfig(list: true, read: true),
          tools: ToolCapabilityConfig(list: true, call: true),
          prompts: PromptCapabilityConfig(list: true, get: true),
        );

        final json = capabilities.toJson();

        // Check that all fields are serialized correctly
        expect(json.containsKey('sampling'), isTrue);
        expect(json.containsKey('resources'), isTrue);
        expect(json.containsKey('tools'), isTrue);
        expect(json.containsKey('prompts'), isTrue);
      });

      test('can be deserialized from JSON', () {
        final json = {
          'sampling': {'sample': true},
          'resources': {'list': true, 'read': true},
          'tools': {'list': true, 'call': true},
          'prompts': {'list': true, 'get': true},
        };

        final capabilities = ClientCapabilities.fromJson(json);

        // Check that all fields are deserialized correctly
        expect(capabilities.sampling, isNotNull);
        expect(capabilities.resources, isNotNull);
        expect(capabilities.tools, isNotNull);
        expect(capabilities.prompts, isNotNull);

        // Check that all fields have the expected values
        expect(capabilities.sampling?.sample, isTrue);
        expect(capabilities.resources?.list, isTrue);
        expect(capabilities.resources?.read, isTrue);
        expect(capabilities.tools?.list, isTrue);
        expect(capabilities.tools?.call, isTrue);
        expect(capabilities.prompts?.list, isTrue);
        expect(capabilities.prompts?.get, isTrue);
      });
    });
  });
}
