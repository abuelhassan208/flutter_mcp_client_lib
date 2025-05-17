/// Example of a simple MCP server
///
/// This example shows how to create a simple MCP server that provides resources,
/// tools, and prompts.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

// Using the package import
import 'package:flutter_mcp_client_lib/flutter_mcp.dart';

/// A simple MCP server that uses WebSockets
class SimpleWebSocketServer {
  final Logger _logger = Logger('SimpleWebSocketServer');
  final int port;
  final List<WebSocketChannel> _clients = [];
  HttpServer? _server;

  SimpleWebSocketServer({this.port = 8080});

  Future<void> start() async {
    _logger.info('Starting server on port $port');

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _logger.info('Server listening on ${_server!.address.address}:$port');

    await for (final request in _server!) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        _handleWebSocketRequest(request);
      } else {
        _handleHttpRequest(request);
      }
    }
  }

  Future<void> stop() async {
    _logger.info('Stopping server');

    for (final client in _clients) {
      await client.sink.close();
    }
    _clients.clear();

    await _server?.close();
    _server = null;

    _logger.info('Server stopped');
  }

  void _handleWebSocketRequest(HttpRequest request) async {
    _logger.info('Handling WebSocket request');

    try {
      final socket = await WebSocketTransformer.upgrade(request);
      // Create a WebSocketChannel from the upgraded socket
      final channel = IOWebSocketChannel(socket);
      _clients.add(channel);

      _logger.info('Client connected');

      channel.stream.listen(
        (message) => _handleWebSocketMessage(channel, message),
        onDone: () {
          _logger.info('Client disconnected');
          _clients.remove(channel);
        },
        onError: (error) {
          _logger.severe('WebSocket error: $error');
          _clients.remove(channel);
        },
      );
    } catch (e) {
      _logger.severe('Failed to upgrade WebSocket: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.close();
    }
  }

  void _handleHttpRequest(HttpRequest request) {
    _logger.info(
      'Handling HTTP request: ${request.method} ${request.uri.path}',
    );

    // Set content type
    request.response.headers.add('content-type', 'text/html');
    request.response.write('''
      <!DOCTYPE html>
      <html>
        <head>
          <title>MCP Server</title>
        </head>
        <body>
          <h1>MCP Server</h1>
          <p>This is an MCP server. Connect to it using WebSockets at ws://${request.requestedUri.authority}/mcp</p>
        </body>
      </html>
    ''');
    request.response.close();
  }

  void _handleWebSocketMessage(WebSocketChannel channel, dynamic message) {
    _logger.fine('Received message: $message');

    try {
      _logger.fine('Received message: $message');
      final json = jsonDecode(message as String);

      if (json is! Map<String, dynamic>) {
        _logger.warning('Received invalid JSON: $json');
        _sendErrorResponse(
          channel,
          null,
          JsonRpcErrorCodes.invalidRequest,
          'Invalid request',
        );
        return;
      }

      final jsonRpcMessage = JsonRpcMessage.fromJson(json);

      if (jsonRpcMessage.isRequest) {
        _handleRequest(channel, jsonRpcMessage);
      } else {
        _logger.warning('Received non-request message: $json');
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to handle message: $e\n$stackTrace');
      _sendErrorResponse(
        channel,
        null,
        JsonRpcErrorCodes.parseError,
        'Parse error',
      );
    }
  }

  void _handleRequest(WebSocketChannel channel, JsonRpcMessage message) {
    final method = message.method;
    final id = message.id;

    // Convert id to String if it's not null
    final idStr = id?.toString() ?? "unknown";

    if (method == null || id == null) {
      _sendErrorResponse(
        channel,
        idStr,
        JsonRpcErrorCodes.invalidRequest,
        'Invalid request',
      );
      return;
    }

    switch (method) {
      case 'initialize':
        _handleInitializeRequest(channel, idStr, message.params);
        break;
      case 'listResources':
        _handleListResourcesRequest(channel, idStr);
        break;
      case 'readResource':
        _handleReadResourceRequest(channel, idStr, message.params);
        break;
      case 'listTools':
        _handleListToolsRequest(channel, idStr);
        break;
      case 'callTool':
        _handleCallToolRequest(channel, idStr, message.params);
        break;
      case 'listPrompts':
        _handleListPromptsRequest(channel, idStr);
        break;
      case 'getPrompt':
        _handleGetPromptRequest(channel, idStr, message.params);
        break;
      default:
        _sendErrorResponse(
          channel,
          idStr,
          JsonRpcErrorCodes.methodNotFound,
          'Method not found',
        );
        break;
    }
  }

  void _handleInitializeRequest(
    WebSocketChannel channel,
    String id,
    dynamic params,
  ) {
    _logger.info('Handling initialize request');

    final result = InitializeResult(
      protocolVersion: mcpProtocolVersion,
      serverInfo: McpInfo(name: 'Example MCP Server', version: '1.0.0'),
      capabilities: ServerCapabilities(
        resources: ResourceCapabilityConfig(list: true, read: true),
        tools: ToolCapabilityConfig(list: true, call: true),
        prompts: PromptCapabilityConfig(list: true, get: true),
      ),
    );

    _sendSuccessResponse(channel, id, result.toJson());
  }

  void _handleListResourcesRequest(WebSocketChannel channel, String id) {
    _logger.info('Handling listResources request');

    final result = ListResourcesResult(
      resources: [
        ResourceInfo(
          name: 'greeting',
          uriTemplate: 'greeting://{name}',
          description: 'A greeting resource',
        ),
        ResourceInfo(
          name: 'time',
          uriTemplate: 'time://current',
          description: 'The current time',
        ),
      ],
    );

    _sendSuccessResponse(channel, id, result.toJson());
  }

  void _handleReadResourceRequest(
    WebSocketChannel channel,
    String id,
    dynamic params,
  ) {
    _logger.info('Handling readResource request');

    if (params is! Map<String, dynamic>) {
      _sendErrorResponse(
        channel,
        id,
        JsonRpcErrorCodes.invalidParams,
        'Invalid params',
      );
      return;
    }

    final readParams = ReadResourceParams.fromJson(params);
    final uri = readParams.uri;

    if (uri.startsWith('greeting://')) {
      final name = uri.substring('greeting://'.length);
      final result = ReadResourceResult(
        contents: [ResourceContent(uri: uri, text: 'Hello, $name!')],
      );
      _sendSuccessResponse(channel, id, result.toJson());
    } else if (uri == 'time://current') {
      final result = ReadResourceResult(
        contents: [
          ResourceContent(
            uri: uri,
            text: 'The current time is ${DateTime.now()}',
          ),
        ],
      );
      _sendSuccessResponse(channel, id, result.toJson());
    } else {
      _sendErrorResponse(
        channel,
        id,
        McpErrorCodes.resourceNotFound,
        'Resource not found',
      );
    }
  }

  void _handleListToolsRequest(WebSocketChannel channel, String id) {
    _logger.info('Handling listTools request');

    final result = ListToolsResult(
      tools: [
        ToolInfo(
          name: 'add',
          description: 'Add two numbers',
          arguments: [
            ToolArgument(
              name: 'a',
              description: 'First number',
              required: true,
            ),
            ToolArgument(
              name: 'b',
              description: 'Second number',
              required: true,
            ),
          ],
        ),
        ToolInfo(
          name: 'echo',
          description: 'Echo a message',
          arguments: [
            ToolArgument(
              name: 'message',
              description: 'Message to echo',
              required: true,
            ),
          ],
        ),
      ],
    );

    _sendSuccessResponse(channel, id, result.toJson());
  }

  void _handleCallToolRequest(
    WebSocketChannel channel,
    String id,
    dynamic params,
  ) {
    _logger.info('Handling callTool request');

    if (params is! Map<String, dynamic>) {
      _sendErrorResponse(
        channel,
        id,
        JsonRpcErrorCodes.invalidParams,
        'Invalid params',
      );
      return;
    }

    final callParams = CallToolParams.fromJson(params);
    final name = callParams.name;
    final arguments = callParams.arguments;

    switch (name) {
      case 'add':
        final a = num.tryParse(arguments['a'].toString());
        final b = num.tryParse(arguments['b'].toString());

        if (a == null || b == null) {
          _sendErrorResponse(
            channel,
            id,
            JsonRpcErrorCodes.invalidParams,
            'Invalid params',
          );
          return;
        }

        final result = CallToolResult(
          content: [ContentItem(type: ContentType.text, text: '${a + b}')],
        );
        _sendSuccessResponse(channel, id, result.toJson());
        break;

      case 'echo':
        final message = arguments['message']?.toString();

        if (message == null) {
          _sendErrorResponse(
            channel,
            id,
            JsonRpcErrorCodes.invalidParams,
            'Invalid params',
          );
          return;
        }

        final result = CallToolResult(
          content: [ContentItem(type: ContentType.text, text: message)],
        );
        _sendSuccessResponse(channel, id, result.toJson());
        break;

      default:
        _sendErrorResponse(
          channel,
          id,
          McpErrorCodes.toolNotFound,
          'Tool not found',
        );
        break;
    }
  }

  void _handleListPromptsRequest(WebSocketChannel channel, String id) {
    _logger.info('Handling listPrompts request');

    final result = ListPromptsResult(
      prompts: [
        PromptInfo(
          name: 'greeting',
          description: 'A greeting prompt',
          arguments: [
            PromptArgument(
              name: 'name',
              description: 'Name to greet',
              required: true,
            ),
          ],
        ),
      ],
    );

    _sendSuccessResponse(channel, id, result.toJson());
  }

  void _handleGetPromptRequest(
    WebSocketChannel channel,
    String id,
    dynamic params,
  ) {
    _logger.info('Handling getPrompt request');

    if (params is! Map<String, dynamic>) {
      _sendErrorResponse(
        channel,
        id,
        JsonRpcErrorCodes.invalidParams,
        'Invalid params',
      );
      return;
    }

    final getParams = GetPromptParams.fromJson(params);
    final name = getParams.name;
    final arguments = getParams.arguments;

    if (name == 'greeting') {
      final nameArg = arguments['name']?.toString();

      if (nameArg == null) {
        _sendErrorResponse(
          channel,
          id,
          JsonRpcErrorCodes.invalidParams,
          'Invalid params',
        );
        return;
      }

      final result = GetPromptResult(
        description: 'A greeting prompt',
        messages: [
          Message(
            role: MessageRole.system,
            content: MessageContent(
              type: 'text',
              text: 'You are a helpful assistant.',
            ),
          ),
          Message(
            role: MessageRole.user,
            content: MessageContent(type: 'text', text: 'Hello, $nameArg!'),
          ),
        ],
      );
      _sendSuccessResponse(channel, id, result.toJson());
    } else {
      _sendErrorResponse(
        channel,
        id,
        McpErrorCodes.promptNotFound,
        'Prompt not found',
      );
    }
  }

  void _sendSuccessResponse(
    WebSocketChannel channel,
    String id,
    Map<String, dynamic> result,
  ) {
    final response = {'jsonrpc': '2.0', 'id': id, 'result': result};

    channel.sink.add(jsonEncode(response));
  }

  void _sendErrorResponse(
    WebSocketChannel channel,
    String? id,
    int code,
    String message,
  ) {
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': code, 'message': message},
    };

    channel.sink.add(jsonEncode(response));
  }
}

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // Using stderr instead of print
    stderr.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  final server = SimpleWebSocketServer();

  // Handle shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
    exit(0);
  });

  await server.start();
}
