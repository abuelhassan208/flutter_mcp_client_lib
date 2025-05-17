import 'dart:async';
import 'package:flutter_mcp_client_lib/flutter_mcp.dart';
import 'package:equatable/equatable.dart';

// Re-export the MockMcpResponse class for use in test helpers
export 'package:flutter_mcp_client_lib/flutter_mcp.dart' show mcpProtocolVersion;

class MockMcpClientTransport implements McpClientTransport {
  // Custom field to store the response to return from sendRequest
  McpResponse? sendRequestResponse;
  bool _isConnected = false;
  ServerCapabilities? _serverCapabilities;

  @override
  bool get isConnected => _isConnected;

  @override
  ServerCapabilities? get serverCapabilities => _serverCapabilities;

  void setServerCapabilities(ServerCapabilities capabilities) {
    _serverCapabilities = capabilities;
  }

  @override
  Future<void> connect() async {
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _serverCapabilities = null;
  }

  @override
  Future<McpResponse> sendRequest(McpRequest request) async {
    // Return the custom response if set, otherwise a default response
    return sendRequestResponse ?? MockMcpResponse(id: request.id, result: {});
  }

  @override
  Future<void> sendNotification(McpNotification notification) async {
    // No-op implementation for tests
  }

  @override
  Future<void> sendResponse(McpResponse response) async {
    // No-op implementation for tests
  }

  // Controllers for the request and notification streams
  final _requestsController = StreamController<McpRequest>.broadcast();
  final _notificationsController = StreamController<McpNotification>.broadcast();

  @override
  Stream<McpRequest> get requests => _requestsController.stream;

  @override
  Stream<McpNotification> get notifications => _notificationsController.stream;
}

class MockMcpResponse extends Equatable implements McpResponse {
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

  const MockMcpResponse({required this.id, this.result, this.error})
    : assert(
        (result != null && error == null) || (result == null && error != null),
        'Either result or error must be provided, but not both',
      );

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    if (result != null) 'result': result,
    if (error != null) 'error': error!.toJson(),
  };

  @override
  List<Object?> get props => [jsonrpc, id, result, error];

  @override
  bool? get stringify => true;
}

class MockMcpError extends Equatable implements McpError {
  @override
  final int code;

  @override
  final String message;

  @override
  final Map<String, dynamic>? data;

  const MockMcpError({required this.code, required this.message, this.data});

  @override
  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (data != null) 'data': data,
  };

  @override
  List<Object?> get props => [code, message, data];

  @override
  bool? get stringify => true;
}

class MockMcpNotification extends Equatable implements McpNotification {
  @override
  final String method;

  @override
  final Map<String, dynamic>? params;

  @override
  final String jsonrpc = '2.0';

  const MockMcpNotification({required this.method, this.params});

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'method': method,
    if (params != null) 'params': params,
  };

  @override
  List<Object?> get props => [jsonrpc, method, params];

  @override
  bool? get stringify => true;
}
