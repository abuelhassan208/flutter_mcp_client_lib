/// MCP tool models
///
/// This file contains the models for MCP tools, which are used to provide
/// functionality to LLMs.
library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mcp_concrete.dart';
import 'mcp_types.dart';

part 'mcp_tools.g.dart';

/// A tool argument
@JsonSerializable()
class ToolArgument extends Equatable {
  /// The name of the argument
  final String name;

  /// Optional description of the argument
  final String? description;

  /// Whether the argument is required
  final bool required;

  /// Optional schema for the argument
  final Map<String, dynamic>? schema;

  const ToolArgument({
    required this.name,
    this.description,
    required this.required,
    this.schema,
  });

  /// Create a tool argument from a JSON map
  factory ToolArgument.fromJson(Map<String, dynamic> json) =>
      _$ToolArgumentFromJson(json);

  /// Convert the tool argument to a JSON map
  Map<String, dynamic> toJson() => _$ToolArgumentToJson(this);

  @override
  List<Object?> get props => [name, description, required, schema];
}

/// Information about a tool
@JsonSerializable()
class ToolInfo extends Equatable {
  /// The name of the tool
  final String name;

  /// Optional description of the tool
  final String? description;

  /// The arguments for the tool
  final List<ToolArgument> arguments;

  const ToolInfo({
    required this.name,
    this.description,
    required this.arguments,
  });

  /// Create tool info from a JSON map
  factory ToolInfo.fromJson(Map<String, dynamic> json) =>
      _$ToolInfoFromJson(json);

  /// Convert tool info to a JSON map
  Map<String, dynamic> toJson() => _$ToolInfoToJson(this);

  @override
  List<Object?> get props => [name, description, arguments];
}

/// List tools request
class ListToolsRequest {
  /// The request ID
  final String id;

  /// Create a list tools request
  const ListToolsRequest({required this.id});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'listTools', id: id);
  }
}

/// List tools response result
@JsonSerializable()
class ListToolsResult extends Equatable {
  /// The list of available tools
  final List<ToolInfo> tools;

  const ListToolsResult({required this.tools});

  /// Create list tools result from a JSON map
  factory ListToolsResult.fromJson(Map<String, dynamic> json) =>
      _$ListToolsResultFromJson(json);

  /// Convert list tools result to a JSON map
  Map<String, dynamic> toJson() => _$ListToolsResultToJson(this);

  @override
  List<Object?> get props => [tools];
}

/// List tools response
class ListToolsResponse {
  /// The response ID
  final String id;

  /// The list tools result
  final ListToolsResult result;

  /// Create a list tools response
  const ListToolsResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory ListToolsResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = ListToolsResult.fromJson(response.result!);
    return ListToolsResponse(id: response.id, result: result);
  }
}

/// Content type for tool results
enum ContentType {
  /// Plain text content
  @JsonValue('text')
  text,

  /// Markdown content
  @JsonValue('markdown')
  markdown,

  /// HTML content
  @JsonValue('html')
  html,

  /// JSON content
  @JsonValue('json')
  json,
}

/// A content item in a tool result
@JsonSerializable()
class ContentItem extends Equatable {
  /// The type of content
  final ContentType type;

  /// The content text
  final String text;

  const ContentItem({required this.type, required this.text});

  /// Create a content item from a JSON map
  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  /// Convert the content item to a JSON map
  Map<String, dynamic> toJson() => _$ContentItemToJson(this);

  @override
  List<Object?> get props => [type, text];
}

/// Call tool request parameters
@JsonSerializable()
class CallToolParams extends Equatable {
  /// The name of the tool to call
  final String name;

  /// The arguments to pass to the tool
  final Map<String, dynamic> arguments;

  const CallToolParams({required this.name, required this.arguments});

  /// Create call tool params from a JSON map
  factory CallToolParams.fromJson(Map<String, dynamic> json) =>
      _$CallToolParamsFromJson(json);

  /// Convert call tool params to a JSON map
  Map<String, dynamic> toJson() => _$CallToolParamsToJson(this);

  @override
  List<Object?> get props => [name, arguments];
}

/// Call tool request
class CallToolRequest {
  /// The request ID
  final String id;

  /// The call tool parameters
  final CallToolParams params;

  /// Create a call tool request
  const CallToolRequest({required this.id, required this.params});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'callTool', id: id, params: params.toJson());
  }
}

/// Call tool response result
@JsonSerializable()
class CallToolResult extends Equatable {
  /// The content items in the result
  final List<ContentItem> content;

  /// Whether the result represents an error
  final bool? isError;

  const CallToolResult({required this.content, this.isError});

  /// Create call tool result from a JSON map
  factory CallToolResult.fromJson(Map<String, dynamic> json) =>
      _$CallToolResultFromJson(json);

  /// Convert call tool result to a JSON map
  Map<String, dynamic> toJson() => _$CallToolResultToJson(this);

  @override
  List<Object?> get props => [content, isError];
}

/// Call tool response
class CallToolResponse {
  /// The response ID
  final String id;

  /// The call tool result
  final CallToolResult result;

  /// Create a call tool response
  const CallToolResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory CallToolResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = CallToolResult.fromJson(response.result!);
    return CallToolResponse(id: response.id, result: result);
  }
}

/// Tool list changed notification parameters
@JsonSerializable()
class ToolListChangedParams extends Equatable {
  const ToolListChangedParams();

  /// Create tool list changed params from a JSON map
  factory ToolListChangedParams.fromJson(Map<String, dynamic> json) =>
      _$ToolListChangedParamsFromJson(json);

  /// Convert tool list changed params to a JSON map
  Map<String, dynamic> toJson() => _$ToolListChangedParamsToJson(this);

  @override
  List<Object?> get props => [];
}

/// Tool list changed notification
class ToolListChangedNotification extends McpNotification {
  ToolListChangedNotification()
    : super(
        method: 'toolListChanged',
        params: const ToolListChangedParams().toJson(),
      );
}
