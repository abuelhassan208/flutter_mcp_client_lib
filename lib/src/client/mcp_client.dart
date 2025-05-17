/// MCP client implementation
///
/// This file implements the MCP client, which can be used to connect to
/// MCP servers and use their resources, tools, and prompts.
library mcp_client;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../transports/transport.dart';
import '../transports/websocket_transport.dart';
import '../utils/json_rpc.dart';

/// A client for the Model Context Protocol
class McpClient {
  final Logger _logger = Logger('McpClient');
  final McpInfo _clientInfo;
  final ClientCapabilities _capabilities;
  McpClientTransport? _transport;
  bool _initialized = false;

  /// Create a new MCP client
  McpClient({
    required String name,
    required String version,
    ClientCapabilities? capabilities,
  }) : _clientInfo = McpInfo(name: name, version: version),
       _capabilities = capabilities ?? const ClientCapabilities();

  /// Whether the client is connected to a server
  bool get isConnected => _transport != null && _transport!.isConnected;

  /// Whether the client is initialized
  bool get isInitialized => _initialized;

  /// The server capabilities
  ServerCapabilities? get serverCapabilities => _transport?.serverCapabilities;

  /// Connect to an MCP server
  Future<void> connect(McpClientTransport transport) async {
    if (isConnected) {
      throw StateError('Already connected');
    }

    _transport = transport;
    await _transport!.connect();

    // Listen for requests from the server
    _transport!.requests.listen(_handleRequest);

    // Listen for notifications from the server
    _transport!.notifications.listen(_handleNotification);

    // Initialize the connection
    await _initialize();
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    if (!isConnected) {
      return;
    }

    await _transport!.disconnect();
    _transport = null;
    _initialized = false;
  }

  /// List available resources
  Future<List<ResourceInfo>> listResources() async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('resources.list');

    final listRequest = ListResourcesRequest(id: generateRequestId());
    // Convert to McpRequestImpl before sending
    final request = listRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to ListResourcesResponse
    final listResponse = ListResourcesResponse.fromResponse(response);
    return listResponse.result.resources;
  }

  /// Read a resource
  Future<List<ResourceContent>> readResource(String uri) async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('resources.read');

    final params = ReadResourceParams(uri: uri);
    final readRequest = ReadResourceRequest(
      id: generateRequestId(),
      params: params,
    );
    // Convert to McpRequestImpl before sending
    final request = readRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to ReadResourceResponse
    final readResponse = ReadResourceResponse.fromResponse(response);
    return readResponse.result.contents;
  }

  /// List available tools
  Future<List<ToolInfo>> listTools() async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('tools.list');

    final listRequest = ListToolsRequest(id: generateRequestId());
    // Convert to McpRequestImpl before sending
    final request = listRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to ListToolsResponse
    final listResponse = ListToolsResponse.fromResponse(response);
    return listResponse.result.tools;
  }

  /// Call a tool
  Future<CallToolResult> callTool(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('tools.call');

    final params = CallToolParams(name: name, arguments: arguments);
    final callRequest = CallToolRequest(
      id: generateRequestId(),
      params: params,
    );
    // Convert to McpRequestImpl before sending
    final request = callRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to CallToolResponse
    final callResponse = CallToolResponse.fromResponse(response);
    return callResponse.result;
  }

  /// List available prompts
  Future<List<PromptInfo>> listPrompts() async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('prompts.list');

    final listRequest = ListPromptsRequest(id: generateRequestId());
    // Convert to McpRequestImpl before sending
    final request = listRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to ListPromptsResponse
    final listResponse = ListPromptsResponse.fromResponse(response);
    return listResponse.result.prompts;
  }

  /// Get a prompt
  Future<GetPromptResult> getPrompt(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    _ensureConnected();
    _ensureInitialized();
    _ensureCapability('prompts.get');

    final params = GetPromptParams(name: name, arguments: arguments);
    final getRequest = GetPromptRequest(
      id: generateRequestId(),
      params: params,
    );
    // Convert to McpRequestImpl before sending
    final request = getRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      throw response.error!;
    }

    // Convert from McpResponse to GetPromptResponse
    final getResponse = GetPromptResponse.fromResponse(response);
    return getResponse.result;
  }

  /// Handle a request from the server
  @protected
  Future<void> _handleRequest(McpRequest request) async {
    _logger.fine('Received request: ${request.method}');

    // Currently, the only request a server can send is 'sample'
    if (request.method == 'sample') {
      await _handleSampleRequest(request);
    } else {
      _logger.warning('Received unknown request: ${request.method}');

      // Send an error response
      final response = McpResponseImpl(
        id: request.id,
        error: McpError(
          code: JsonRpcErrorCodes.methodNotFound,
          message: 'Method not found',
        ),
      );
      await _transport!.sendResponse(response);
    }
  }

  /// Handle a sample request from the server
  @protected
  Future<void> _handleSampleRequest(McpRequest request) async {
    // Check if sampling is supported
    if (_capabilities.sampling?.sample != true) {
      final response = McpResponseImpl(
        id: request.id,
        error: McpError(
          code: McpErrorCodes.notSupported,
          message: 'Sampling is not supported',
        ),
      );
      await _transport!.sendResponse(response);
      return;
    }

    // Parse the request parameters
    // This is where you would implement the actual sampling logic
    // For now, we'll just return a simple response without using the params
    // SampleParams.fromJson(request.params!) would be used in a real implementation
    final result = SampleResult(
      message: Message(
        role: MessageRole.assistant,
        content: MessageContent(
          type: 'text',
          text: 'This is a sample response',
        ),
      ),
    );

    final sampleResponse = SampleResponse(id: request.id, result: result);
    // Convert to McpResponseImpl before sending
    final response = sampleResponse.toResponse();

    await _transport!.sendResponse(response);
  }

  /// Handle a notification from the server
  @protected
  void _handleNotification(McpNotification notification) {
    _logger.fine('Received notification: ${notification.method}');

    // Handle different notification types
    switch (notification.method) {
      case 'resourceListChanged':
        _logger.info('Resource list changed');
        break;
      case 'toolListChanged':
        _logger.info('Tool list changed');
        break;
      case 'promptListChanged':
        _logger.info('Prompt list changed');
        break;
      default:
        _logger.warning(
          'Received unknown notification: ${notification.method}',
        );
        break;
    }
  }

  /// Initialize the connection
  Future<void> _initialize() async {
    _logger.info('Initializing connection');

    final params = InitializeParams(
      protocolVersion: mcpProtocolVersion,
      clientInfo: _clientInfo,
      capabilities: _capabilities,
    );

    final initRequest = InitializeRequest(
      id: generateRequestId(),
      params: params,
    );

    // Convert to McpRequestImpl before sending
    final request = initRequest.toRequest();
    final response = await _transport!.sendRequest(request);

    if (response.error != null) {
      _logger.severe('Initialization failed: ${response.error!.message}');
      throw response.error!;
    }

    // Convert from McpResponse to InitializeResponse
    final initResponse = InitializeResponse.fromResponse(response);
    final result = initResponse.result;

    _logger.info(
      'Initialized connection to ${result.serverInfo.name} '
      '${result.serverInfo.version}',
    );

    if (_transport is McpWebSocketClientTransport) {
      (_transport as McpWebSocketClientTransport).setServerCapabilities(
        result.capabilities,
      );
    }

    _initialized = true;
  }

  /// Ensure the client is connected
  void _ensureConnected() {
    if (!isConnected) {
      throw StateError('Not connected');
    }
  }

  /// Ensure the client is initialized
  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('Not initialized');
    }
  }

  /// Ensure a capability is supported
  void _ensureCapability(String capability) {
    if (serverCapabilities == null) {
      throw StateError('Server capabilities not available');
    }

    final parts = capability.split('.');

    if (parts.length != 2) {
      throw ArgumentError('Invalid capability: $capability');
    }

    final category = parts[0];
    final operation = parts[1];

    switch (category) {
      case 'resources':
        final resourceCapabilities = serverCapabilities!.resources;
        if (resourceCapabilities == null) {
          throw UnsupportedError('Resources not supported');
        }

        switch (operation) {
          case 'list':
            if (resourceCapabilities.list != true) {
              throw UnsupportedError('Resource listing not supported');
            }
            break;
          case 'read':
            if (resourceCapabilities.read != true) {
              throw UnsupportedError('Resource reading not supported');
            }
            break;
          default:
            throw ArgumentError('Invalid resource operation: $operation');
        }
        break;

      case 'tools':
        final toolCapabilities = serverCapabilities!.tools;
        if (toolCapabilities == null) {
          throw UnsupportedError('Tools not supported');
        }

        switch (operation) {
          case 'list':
            if (toolCapabilities.list != true) {
              throw UnsupportedError('Tool listing not supported');
            }
            break;
          case 'call':
            if (toolCapabilities.call != true) {
              throw UnsupportedError('Tool calling not supported');
            }
            break;
          default:
            throw ArgumentError('Invalid tool operation: $operation');
        }
        break;

      case 'prompts':
        final promptCapabilities = serverCapabilities!.prompts;
        if (promptCapabilities == null) {
          throw UnsupportedError('Prompts not supported');
        }

        switch (operation) {
          case 'list':
            if (promptCapabilities.list != true) {
              throw UnsupportedError('Prompt listing not supported');
            }
            break;
          case 'get':
            if (promptCapabilities.get != true) {
              throw UnsupportedError('Prompt getting not supported');
            }
            break;
          default:
            throw ArgumentError('Invalid prompt operation: $operation');
        }
        break;

      default:
        throw ArgumentError('Invalid capability category: $category');
    }
  }
}
