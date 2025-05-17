/// MCP capabilities and initialization models
///
/// This file contains the models for MCP capabilities and initialization
/// messages, which are used to establish a connection between a client and server.
library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'mcp_concrete.dart';
import 'mcp_types.dart';

part 'mcp_capabilities.g.dart';

/// Information about an MCP client or server
@JsonSerializable()
class McpInfo extends Equatable {
  /// The name of the client or server
  final String name;

  /// The version of the client or server
  final String version;

  const McpInfo({required this.name, required this.version});

  /// Create an info object from a JSON map
  factory McpInfo.fromJson(Map<String, dynamic> json) =>
      _$McpInfoFromJson(json);

  /// Convert the info object to a JSON map
  Map<String, dynamic> toJson() => _$McpInfoToJson(this);

  @override
  List<Object?> get props => [name, version];
}

/// Base class for capability configurations
@immutable
abstract class CapabilityConfig extends Equatable {
  const CapabilityConfig();

  /// Convert the capability config to a JSON map
  Map<String, dynamic> toJson();
}

/// Configuration for resource capabilities
@JsonSerializable()
class ResourceCapabilityConfig extends CapabilityConfig {
  /// Whether the server supports listing resources
  final bool? list;

  /// Whether the server supports reading resources
  final bool? read;

  const ResourceCapabilityConfig({this.list, this.read});

  /// Create a resource capability config from a JSON map
  factory ResourceCapabilityConfig.fromJson(Map<String, dynamic> json) =>
      _$ResourceCapabilityConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ResourceCapabilityConfigToJson(this);

  @override
  List<Object?> get props => [list, read];
}

/// Configuration for tool capabilities
@JsonSerializable()
class ToolCapabilityConfig extends CapabilityConfig {
  /// Whether the server supports listing tools
  final bool? list;

  /// Whether the server supports calling tools
  final bool? call;

  const ToolCapabilityConfig({this.list, this.call});

  /// Create a tool capability config from a JSON map
  factory ToolCapabilityConfig.fromJson(Map<String, dynamic> json) =>
      _$ToolCapabilityConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ToolCapabilityConfigToJson(this);

  @override
  List<Object?> get props => [list, call];
}

/// Configuration for prompt capabilities
@JsonSerializable()
class PromptCapabilityConfig extends CapabilityConfig {
  /// Whether the server supports listing prompts
  final bool? list;

  /// Whether the server supports getting prompts
  final bool? get;

  const PromptCapabilityConfig({this.list, this.get});

  /// Create a prompt capability config from a JSON map
  factory PromptCapabilityConfig.fromJson(Map<String, dynamic> json) =>
      _$PromptCapabilityConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PromptCapabilityConfigToJson(this);

  @override
  List<Object?> get props => [list, get];
}

/// Configuration for sampling capabilities
@JsonSerializable()
class SamplingCapabilityConfig extends CapabilityConfig {
  /// Whether the client supports sampling
  final bool? sample;

  const SamplingCapabilityConfig({this.sample});

  /// Create a sampling capability config from a JSON map
  factory SamplingCapabilityConfig.fromJson(Map<String, dynamic> json) =>
      _$SamplingCapabilityConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SamplingCapabilityConfigToJson(this);

  @override
  List<Object?> get props => [sample];
}

/// Server capabilities configuration
@JsonSerializable()
class ServerCapabilities extends Equatable {
  /// Resource capabilities
  final ResourceCapabilityConfig? resources;

  /// Tool capabilities
  final ToolCapabilityConfig? tools;

  /// Prompt capabilities
  final PromptCapabilityConfig? prompts;

  const ServerCapabilities({this.resources, this.tools, this.prompts});

  /// Create server capabilities from a JSON map
  factory ServerCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ServerCapabilitiesFromJson(json);

  /// Convert server capabilities to a JSON map
  Map<String, dynamic> toJson() => _$ServerCapabilitiesToJson(this);

  @override
  List<Object?> get props => [resources, tools, prompts];
}

/// Client capabilities configuration
@JsonSerializable()
class ClientCapabilities extends Equatable {
  /// Sampling capabilities
  final SamplingCapabilityConfig? sampling;

  /// Resource capabilities
  final ResourceCapabilityConfig? resources;

  /// Tool capabilities
  final ToolCapabilityConfig? tools;

  /// Prompt capabilities
  final PromptCapabilityConfig? prompts;

  const ClientCapabilities({
    this.sampling,
    this.resources,
    this.tools,
    this.prompts,
  });

  /// Create client capabilities from a JSON map
  factory ClientCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ClientCapabilitiesFromJson(json);

  /// Convert client capabilities to a JSON map
  Map<String, dynamic> toJson() => _$ClientCapabilitiesToJson(this);

  @override
  List<Object?> get props => [sampling, resources, tools, prompts];
}

/// Initialize request parameters
@JsonSerializable()
class InitializeParams extends Equatable {
  /// The protocol version
  final String protocolVersion;

  /// Information about the client
  final McpInfo clientInfo;

  /// The client's capabilities
  final ClientCapabilities? capabilities;

  const InitializeParams({
    required this.protocolVersion,
    required this.clientInfo,
    this.capabilities,
  });

  /// Create initialize params from a JSON map
  factory InitializeParams.fromJson(Map<String, dynamic> json) =>
      _$InitializeParamsFromJson(json);

  /// Convert initialize params to a JSON map
  Map<String, dynamic> toJson() => _$InitializeParamsToJson(this);

  @override
  List<Object?> get props => [protocolVersion, clientInfo, capabilities];
}

/// Initialize request
class InitializeRequest {
  /// The request ID
  final String id;

  /// The initialize parameters
  final InitializeParams params;

  /// Create an initialize request
  const InitializeRequest({required this.id, required this.params});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(
      method: 'initialize',
      id: id,
      params: params.toJson(),
    );
  }
}

/// Initialize response result
@JsonSerializable()
class InitializeResult extends Equatable {
  /// The protocol version
  final String protocolVersion;

  /// Information about the server
  final McpInfo serverInfo;

  /// The server's capabilities
  final ServerCapabilities capabilities;

  const InitializeResult({
    required this.protocolVersion,
    required this.serverInfo,
    required this.capabilities,
  });

  /// Create initialize result from a JSON map
  factory InitializeResult.fromJson(Map<String, dynamic> json) =>
      _$InitializeResultFromJson(json);

  /// Convert initialize result to a JSON map
  Map<String, dynamic> toJson() => _$InitializeResultToJson(this);

  @override
  List<Object?> get props => [protocolVersion, serverInfo, capabilities];
}

/// Initialize response
class InitializeResponse {
  /// The response ID
  final String id;

  /// The initialize result
  final InitializeResult result;

  /// Create an initialize response
  const InitializeResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory InitializeResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = InitializeResult.fromJson(response.result!);
    return InitializeResponse(id: response.id, result: result);
  }
}
