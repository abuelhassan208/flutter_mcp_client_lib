/// JSON-RPC utilities
///
/// This file contains utilities for working with JSON-RPC messages.
library;

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A JSON-RPC message
@immutable
class JsonRpcMessage extends Equatable {
  /// The JSON-RPC version
  final String jsonrpc;

  /// The method name (for requests and notifications)
  final String? method;

  /// The request ID (for requests and responses)
  final dynamic id;

  /// The parameters (for requests and notifications)
  final dynamic params;

  /// The result (for successful responses)
  final dynamic result;

  /// The error (for error responses)
  final dynamic error;

  const JsonRpcMessage({
    required this.jsonrpc,
    this.method,
    this.id,
    this.params,
    this.result,
    this.error,
  });

  /// Create a JSON-RPC message from a JSON map
  factory JsonRpcMessage.fromJson(Map<String, dynamic> json) {
    // Handle the case where jsonrpc might be null
    final jsonrpc = json['jsonrpc']?.toString() ?? '2.0';

    return JsonRpcMessage(
      jsonrpc: jsonrpc,
      method: json['method'] as String?,
      id: json['id'],
      params: json['params'],
      result: json['result'],
      error: json['error'],
    );
  }

  /// Whether this is a request message
  bool get isRequest => method != null && id != null;

  /// Whether this is a notification message
  bool get isNotification => method != null && id == null;

  /// Whether this is a response message
  bool get isResponse => method == null && id != null;

  /// Whether this is a successful response
  bool get isSuccessResponse => isResponse && result != null && error == null;

  /// Whether this is an error response
  bool get isErrorResponse => isResponse && result == null && error != null;

  @override
  List<Object?> get props => [jsonrpc, method, id, params, result, error];
}

/// Generate a random request ID
String generateRequestId() {
  // Use a timestamp-based ID for simplicity
  return DateTime.now().millisecondsSinceEpoch.toString();
}
