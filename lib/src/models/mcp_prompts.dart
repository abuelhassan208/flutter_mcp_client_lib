/// MCP prompt models
///
/// This file contains the models for MCP prompts, which are used to provide
/// templated messages for LLM interactions.
library mcp_prompts;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mcp_concrete.dart';
import 'mcp_types.dart';

part 'mcp_prompts.g.dart';

/// A prompt argument
@JsonSerializable()
class PromptArgument extends Equatable {
  /// The name of the argument
  final String name;

  /// Optional description of the argument
  final String? description;

  /// Whether the argument is required
  final bool required;

  /// Optional schema for the argument
  final Map<String, dynamic>? schema;

  const PromptArgument({
    required this.name,
    this.description,
    required this.required,
    this.schema,
  });

  /// Create a prompt argument from a JSON map
  factory PromptArgument.fromJson(Map<String, dynamic> json) =>
      _$PromptArgumentFromJson(json);

  /// Convert the prompt argument to a JSON map
  Map<String, dynamic> toJson() => _$PromptArgumentToJson(this);

  @override
  List<Object?> get props => [name, description, required, schema];
}

/// Information about a prompt
@JsonSerializable()
class PromptInfo extends Equatable {
  /// The name of the prompt
  final String name;

  /// Optional description of the prompt
  final String? description;

  /// The arguments for the prompt
  final List<PromptArgument> arguments;

  const PromptInfo({
    required this.name,
    this.description,
    required this.arguments,
  });

  /// Create prompt info from a JSON map
  factory PromptInfo.fromJson(Map<String, dynamic> json) =>
      _$PromptInfoFromJson(json);

  /// Convert prompt info to a JSON map
  Map<String, dynamic> toJson() => _$PromptInfoToJson(this);

  @override
  List<Object?> get props => [name, description, arguments];
}

/// List prompts request
class ListPromptsRequest {
  /// The request ID
  final String id;

  /// Create a list prompts request
  const ListPromptsRequest({required this.id});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'listPrompts', id: id);
  }
}

/// List prompts response result
@JsonSerializable()
class ListPromptsResult extends Equatable {
  /// The list of available prompts
  final List<PromptInfo> prompts;

  const ListPromptsResult({required this.prompts});

  /// Create list prompts result from a JSON map
  factory ListPromptsResult.fromJson(Map<String, dynamic> json) =>
      _$ListPromptsResultFromJson(json);

  /// Convert list prompts result to a JSON map
  Map<String, dynamic> toJson() => _$ListPromptsResultToJson(this);

  @override
  List<Object?> get props => [prompts];
}

/// List prompts response
class ListPromptsResponse {
  /// The response ID
  final String id;

  /// The list prompts result
  final ListPromptsResult result;

  /// Create a list prompts response
  const ListPromptsResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory ListPromptsResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = ListPromptsResult.fromJson(response.result!);
    return ListPromptsResponse(id: response.id, result: result);
  }
}

/// Message role in a conversation
enum MessageRole {
  /// A message from the user
  @JsonValue('user')
  user,

  /// A message from the assistant
  @JsonValue('assistant')
  assistant,

  /// A system message
  @JsonValue('system')
  system,
}

/// Message content in a conversation
@JsonSerializable()
class MessageContent extends Equatable {
  /// The type of content
  final String type;

  /// The content text
  final String text;

  const MessageContent({required this.type, required this.text});

  /// Create message content from a JSON map
  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  /// Convert message content to a JSON map
  Map<String, dynamic> toJson() => _$MessageContentToJson(this);

  @override
  List<Object?> get props => [type, text];
}

/// A message in a conversation
@JsonSerializable()
class Message extends Equatable {
  /// The role of the message sender
  final MessageRole role;

  /// The content of the message
  final MessageContent content;

  const Message({required this.role, required this.content});

  /// Create a message from a JSON map
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Convert the message to a JSON map
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  List<Object?> get props => [role, content];
}

/// Get prompt request parameters
@JsonSerializable()
class GetPromptParams extends Equatable {
  /// The name of the prompt to get
  final String name;

  /// The arguments to pass to the prompt
  final Map<String, dynamic> arguments;

  const GetPromptParams({required this.name, required this.arguments});

  /// Create get prompt params from a JSON map
  factory GetPromptParams.fromJson(Map<String, dynamic> json) =>
      _$GetPromptParamsFromJson(json);

  /// Convert get prompt params to a JSON map
  Map<String, dynamic> toJson() => _$GetPromptParamsToJson(this);

  @override
  List<Object?> get props => [name, arguments];
}

/// Get prompt request
class GetPromptRequest {
  /// The request ID
  final String id;

  /// The get prompt parameters
  final GetPromptParams params;

  /// Create a get prompt request
  const GetPromptRequest({required this.id, required this.params});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'getPrompt', id: id, params: params.toJson());
  }
}

/// Get prompt response result
@JsonSerializable()
class GetPromptResult extends Equatable {
  /// Optional description of the prompt
  final String? description;

  /// The messages in the prompt
  final List<Message> messages;

  const GetPromptResult({this.description, required this.messages});

  /// Create get prompt result from a JSON map
  factory GetPromptResult.fromJson(Map<String, dynamic> json) =>
      _$GetPromptResultFromJson(json);

  /// Convert get prompt result to a JSON map
  Map<String, dynamic> toJson() => _$GetPromptResultToJson(this);

  @override
  List<Object?> get props => [description, messages];
}

/// Get prompt response
class GetPromptResponse {
  /// The response ID
  final String id;

  /// The get prompt result
  final GetPromptResult result;

  /// Create a get prompt response
  const GetPromptResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory GetPromptResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = GetPromptResult.fromJson(response.result!);
    return GetPromptResponse(id: response.id, result: result);
  }
}

/// Prompt list changed notification parameters
@JsonSerializable()
class PromptListChangedParams extends Equatable {
  const PromptListChangedParams();

  /// Create prompt list changed params from a JSON map
  factory PromptListChangedParams.fromJson(Map<String, dynamic> json) =>
      _$PromptListChangedParamsFromJson(json);

  /// Convert prompt list changed params to a JSON map
  Map<String, dynamic> toJson() => _$PromptListChangedParamsToJson(this);

  @override
  List<Object?> get props => [];
}

/// Prompt list changed notification
class PromptListChangedNotification extends McpNotification {
  PromptListChangedNotification()
    : super(
        method: 'promptListChanged',
        params: const PromptListChangedParams().toJson(),
      );
}
