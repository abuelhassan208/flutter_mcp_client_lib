/// WebSocket transport for MCP
///
/// This file implements a WebSocket transport for MCP, which can be used
/// for both clients and servers.
library;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';
import '../utils/json_rpc.dart';
import 'transport.dart';

/// A WebSocket transport for MCP clients
class McpWebSocketClientTransport extends McpClientTransport {
  final Logger _logger = Logger('McpWebSocketClientTransport');
  final Uri _uri;
  WebSocketChannel? _channel;
  final StreamController<McpRequest> _requestController =
      StreamController<McpRequest>.broadcast();
  final StreamController<McpNotification> _notificationController =
      StreamController<McpNotification>.broadcast();
  final Map<String, Completer<McpResponse>> _pendingRequests = {};
  ServerCapabilities? _serverCapabilities;

  /// Create a new WebSocket client transport
  McpWebSocketClientTransport(this._uri);

  @override
  bool get isConnected => _channel != null;

  @override
  ServerCapabilities? get serverCapabilities => _serverCapabilities;

  @override
  Future<void> connect() async {
    if (isConnected) {
      return;
    }

    _logger.info('Connecting to ${_uri.toString()}');

    try {
      _channel = WebSocketChannel.connect(_uri);

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          _logger.severe('WebSocket error: $error');
          disconnect();
        },
        onDone: () {
          _logger.info('WebSocket connection closed');
          disconnect();
        },
      );

      _logger.info('Connected to ${_uri.toString()}');
    } catch (e) {
      _logger.severe('Failed to connect to ${_uri.toString()}: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (!isConnected) {
      return;
    }

    _logger.info('Disconnecting from ${_uri.toString()}');

    try {
      await _channel!.sink.close();
      _channel = null;

      // Complete all pending requests with an error
      for (final completer in _pendingRequests.values) {
        completer.completeError(
          McpError(code: McpErrorCodes.cancelled, message: 'Connection closed'),
        );
      }
      _pendingRequests.clear();

      _logger.info('Disconnected from ${_uri.toString()}');
    } catch (e) {
      _logger.severe('Failed to disconnect from ${_uri.toString()}: $e');
      rethrow;
    }
  }

  @override
  Stream<McpRequest> get requests => _requestController.stream;

  @override
  Stream<McpNotification> get notifications => _notificationController.stream;

  @override
  Future<McpResponse> sendRequest(McpRequest request) async {
    if (!isConnected) {
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Not connected',
      );
    }

    _logger.fine('Sending request: ${request.method}');

    final completer = Completer<McpResponse>();
    _pendingRequests[request.id] = completer;

    try {
      _channel!.sink.add(jsonEncode(request.toJson()));
    } catch (e) {
      _pendingRequests.remove(request.id);
      _logger.severe('Failed to send request: $e');
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Failed to send request: $e',
      );
    }

    return completer.future;
  }

  @override
  Future<void> sendNotification(McpNotification notification) async {
    if (!isConnected) {
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Not connected',
      );
    }

    _logger.fine('Sending notification: ${notification.method}');

    try {
      _channel!.sink.add(jsonEncode(notification.toJson()));
    } catch (e) {
      _logger.severe('Failed to send notification: $e');
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Failed to send notification: $e',
      );
    }
  }

  @override
  Future<void> sendResponse(McpResponse response) async {
    if (!isConnected) {
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Not connected',
      );
    }

    _logger.fine('Sending response: ${response.id}');

    try {
      _channel!.sink.add(jsonEncode(response.toJson()));
    } catch (e) {
      _logger.severe('Failed to send response: $e');
      throw McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Failed to send response: $e',
      );
    }
  }

  /// Set the server capabilities
  void setServerCapabilities(ServerCapabilities capabilities) {
    _serverCapabilities = capabilities;
  }

  /// Handle an incoming message
  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String);

      if (json is! Map<String, dynamic>) {
        _logger.warning('Received invalid message: $json');
        return;
      }

      final jsonRpcMessage = JsonRpcMessage.fromJson(json);

      if (jsonRpcMessage.isResponse) {
        _handleResponse(jsonRpcMessage);
      } else if (jsonRpcMessage.isRequest) {
        _handleRequest(jsonRpcMessage);
      } else if (jsonRpcMessage.isNotification) {
        _handleNotification(jsonRpcMessage);
      } else {
        _logger.warning('Received unknown message type: $json');
      }
    } catch (e) {
      _logger.severe('Failed to handle message: $e');
    }
  }

  /// Handle an incoming response
  void _handleResponse(JsonRpcMessage message) {
    final id = message.id as String?;

    if (id == null) {
      _logger.warning('Received response without ID: $message');
      return;
    }

    final completer = _pendingRequests.remove(id);

    if (completer == null) {
      _logger.warning('Received response for unknown request: $id');
      return;
    }

    if (message.error != null) {
      final error = McpError.fromJson(message.error!);
      _logger.warning('Received error response: $error');
      completer.completeError(error);
    } else if (message.result != null) {
      final response = McpResponseImpl(
        id: id,
        result: message.result as Map<String, dynamic>,
      );
      _logger.fine('Received success response: $id');
      completer.complete(response);
    } else {
      _logger.warning('Received invalid response: $message');
      completer.completeError(
        McpError(
          code: JsonRpcErrorCodes.invalidRequest,
          message: 'Invalid response',
        ),
      );
    }
  }

  /// Handle an incoming request
  void _handleRequest(JsonRpcMessage message) {
    final method = message.method;
    final id = message.id as String?;

    if (method == null || id == null) {
      _logger.warning('Received invalid request: $message');
      return;
    }

    final request = McpRequestImpl(
      method: method,
      id: id,
      params: message.params as Map<String, dynamic>?,
    );

    _logger.fine('Received request: $method');
    _requestController.add(request);
  }

  /// Handle an incoming notification
  void _handleNotification(JsonRpcMessage message) {
    final method = message.method;

    if (method == null) {
      _logger.warning('Received invalid notification: $message');
      return;
    }

    final notification = McpNotificationImpl(
      method: method,
      params: message.params as Map<String, dynamic>?,
    );

    _logger.fine('Received notification: $method');
    _notificationController.add(notification);
  }
}
