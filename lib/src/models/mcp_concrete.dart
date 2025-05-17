/// Concrete implementations of MCP abstract classes
///
/// This file provides concrete implementations of the abstract classes defined
/// in the MCP protocol.
library mcp_concrete;

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
    final json = <String, dynamic>{
      'jsonrpc': jsonrpc,
      'method': method,
      'id': id,
    };

    if (params != null) {
      json['params'] = params;
    }

    return json;
  }
}

/// A concrete implementation of McpResponse
@JsonSerializable()
class McpResponseImpl extends McpResponse {
  /// Create a new MCP response
  const McpResponseImpl({required super.id, super.result, super.error});

  /// Create a response from a JSON map
  factory McpResponseImpl.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final result = json['result'] as Map<String, dynamic>?;
    final errorJson = json['error'] as Map<String, dynamic>?;

    final error = errorJson != null ? McpError.fromJson(errorJson) : null;

    return McpResponseImpl(id: id, result: result, error: error);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'jsonrpc': jsonrpc, 'id': id};

    if (result != null) {
      json['result'] = result;
    }

    if (error != null) {
      json['error'] = error!.toJson();
    }

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
