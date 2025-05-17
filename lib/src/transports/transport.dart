/// MCP transport interface
///
/// This file defines the interface for MCP transports, which are responsible
/// for sending and receiving MCP messages.
library;

import 'dart:async';

import '../models/models.dart';

/// A transport for MCP messages
abstract class McpTransport {
  /// Whether the transport is connected
  bool get isConnected;

  /// Connect the transport
  Future<void> connect();

  /// Disconnect the transport
  Future<void> disconnect();

  /// Send a request and wait for a response
  Future<McpResponse> sendRequest(McpRequest request);

  /// Send a notification
  Future<void> sendNotification(McpNotification notification);

  /// Stream of incoming requests
  Stream<McpRequest> get requests;

  /// Stream of incoming notifications
  Stream<McpNotification> get notifications;

  /// Send a response to a request
  Future<void> sendResponse(McpResponse response);
}

/// A transport for MCP clients
abstract class McpClientTransport extends McpTransport {
  /// The server capabilities
  ServerCapabilities? get serverCapabilities;
}

/// A transport for MCP servers
abstract class McpServerTransport extends McpTransport {
  /// The client capabilities
  ClientCapabilities? get clientCapabilities;
}
