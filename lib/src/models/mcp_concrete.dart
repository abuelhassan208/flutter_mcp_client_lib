/// Concrete implementations of MCP abstract classes
///
/// This file provides concrete implementations of the abstract classes defined
/// in the MCP protocol.
library;

import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'mcp_concrete.g.dart';

/// A concrete implementation of McpRequest
@JsonSerializable()
class McpRequestImpl extends McpRequest {
  /// Create a new MCP request
  const McpRequestImpl({
    required super.method,
    required super.id,
    super.params,
  });

  /// Create a request from a JSON map
  factory McpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$McpRequestImplFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    // Start with the generated JSON
    final json = _$McpRequestImplToJson(this);

    // Add the jsonrpc field
    json['jsonrpc'] = jsonrpc;

    return json;
  }
}

/// A concrete implementation of McpResponse
@JsonSerializable()
class McpResponseImpl extends McpResponse {
  /// Create a new MCP response
  const McpResponseImpl({required super.id, super.result, super.error});

  /// Create a response from a JSON map
  factory McpResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$McpResponseImplFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    // Start with the generated JSON
    final json = _$McpResponseImplToJson(this);

    // Add the jsonrpc field
    json['jsonrpc'] = jsonrpc;

    return json;
  }
}

/// A concrete implementation of McpNotification
@JsonSerializable()
class McpNotificationImpl extends McpNotification {
  /// Create a new MCP notification
  const McpNotificationImpl({required super.method, super.params});

  /// Create a notification from a JSON map
  factory McpNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$McpNotificationImplFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$McpNotificationImplToJson(this);
}
