/// MCP sampling models
///
/// This file contains the models for MCP sampling, which allows servers to
/// request LLM interactions from clients.
library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mcp_concrete.dart';
import 'mcp_prompts.dart';
import 'mcp_types.dart';

part 'mcp_sampling.g.dart';

/// Sample request parameters
@JsonSerializable()
class SampleParams extends Equatable {
  /// The messages to sample from
  final List<Message> messages;

  /// Optional sampling options
  final Map<String, dynamic>? options;

  const SampleParams({required this.messages, this.options});

  /// Create sample params from a JSON map
  factory SampleParams.fromJson(Map<String, dynamic> json) =>
      _$SampleParamsFromJson(json);

  /// Convert sample params to a JSON map
  Map<String, dynamic> toJson() => _$SampleParamsToJson(this);

  @override
  List<Object?> get props => [messages, options];
}

/// Sample request
class SampleRequest {
  /// The request ID
  final String id;

  /// The sample parameters
  final SampleParams params;

  /// Create a sample request
  const SampleRequest({required this.id, required this.params});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'sample', id: id, params: params.toJson());
  }
}

/// Sample response result
@JsonSerializable()
class SampleResult extends Equatable {
  /// The sampled message
  final Message message;

  const SampleResult({required this.message});

  /// Create sample result from a JSON map
  factory SampleResult.fromJson(Map<String, dynamic> json) =>
      _$SampleResultFromJson(json);

  /// Convert sample result to a JSON map
  Map<String, dynamic> toJson() => _$SampleResultToJson(this);

  @override
  List<Object?> get props => [message];
}

/// Sample response
class SampleResponse {
  /// The response ID
  final String id;

  /// The sample result
  final SampleResult result;

  /// Create a sample response
  const SampleResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory SampleResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = SampleResult.fromJson(response.result!);
    return SampleResponse(id: response.id, result: result);
  }
}
