/// Core types for the Model Context Protocol (MCP)
///
/// This file contains the basic types and interfaces used in the MCP protocol.
/// These types are based on the official MCP specification.
library mcp_types;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'mcp_types.g.dart';

/// The current version of the MCP protocol implemented by this package
const String mcpProtocolVersion = '2025-03-26';

/// Base class for all MCP messages
@immutable
abstract class McpMessage extends Equatable {
  /// JSON-RPC version, always "2.0"
  final String jsonrpc = '2.0';

  const McpMessage();

  /// Convert the message to a JSON map
  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [jsonrpc];
}

/// Base class for all MCP requests
@immutable
abstract class McpRequest extends McpMessage {
  /// The method to be invoked
  final String method;

  /// The request ID
  final String id;

  /// Optional parameters for the request
  final Map<String, dynamic>? params;

  const McpRequest({required this.method, required this.id, this.params});

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'method': method,
    'id': id,
    if (params != null) 'params': params,
  };

  @override
  List<Object?> get props => [...super.props, method, id, params];
}

/// Base class for all MCP responses
@immutable
abstract class McpResponse extends McpMessage {
  /// The ID of the request this response is for
  final String id;

  /// The result of the request, if successful
  final Map<String, dynamic>? result;

  /// The error, if the request failed
  final McpError? error;

  const McpResponse({required this.id, this.result, this.error})
    : assert(
        (result != null && error == null) || (result == null && error != null),
        'Either result or error must be provided, but not both',
      );

  /// Whether the response indicates success
  bool get isSuccess => error == null;

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    if (result != null) 'result': result,
    if (error != null) 'error': error!.toJson(),
  };

  @override
  List<Object?> get props => [...super.props, id, result, error];
}

/// Error information for MCP responses
@JsonSerializable()
class McpError extends Equatable {
  /// The error code
  final int code;

  /// The error message
  final String message;

  /// Optional additional data about the error
  final Map<String, dynamic>? data;

  const McpError({required this.code, required this.message, this.data});

  /// Create an error from a JSON map
  factory McpError.fromJson(Map<String, dynamic> json) =>
      _$McpErrorFromJson(json);

  /// Convert the error to a JSON map
  Map<String, dynamic> toJson() => _$McpErrorToJson(this);

  @override
  List<Object?> get props => [code, message, data];
}

/// Base class for all MCP notifications
@immutable
abstract class McpNotification extends McpMessage {
  /// The method being notified
  final String method;

  /// Optional parameters for the notification
  final Map<String, dynamic>? params;

  const McpNotification({required this.method, this.params});

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'method': method,
    if (params != null) 'params': params,
  };

  @override
  List<Object?> get props => [...super.props, method, params];
}

/// Standard error codes defined by the JSON-RPC 2.0 specification
class JsonRpcErrorCodes {
  /// Invalid JSON was received by the server.
  static const int parseError = -32700;

  /// The JSON sent is not a valid Request object.
  static const int invalidRequest = -32600;

  /// The method does not exist / is not available.
  static const int methodNotFound = -32601;

  /// Invalid method parameter(s).
  static const int invalidParams = -32602;

  /// Internal JSON-RPC error.
  static const int internalError = -32603;

  /// Reserved for implementation-defined server-errors.
  static const int serverErrorStart = -32099;
  static const int serverErrorEnd = -32000;
}

/// MCP-specific error codes
class McpErrorCodes {
  /// The requested resource was not found
  static const int resourceNotFound = -33000;

  /// The requested tool was not found
  static const int toolNotFound = -33001;

  /// The requested prompt was not found
  static const int promptNotFound = -33002;

  /// The operation was cancelled
  static const int cancelled = -33003;

  /// The operation timed out
  static const int timeout = -33004;

  /// The client is not authorized to perform the operation
  static const int unauthorized = -33005;

  /// The operation is not supported
  static const int notSupported = -33006;
}
