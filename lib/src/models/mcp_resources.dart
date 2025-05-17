/// MCP resource models
///
/// This file contains the models for MCP resources, which are used to provide
/// contextual information to LLMs.
library mcp_resources;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mcp_concrete.dart';
import 'mcp_types.dart';

part 'mcp_resources.g.dart';

/// A resource content item
@JsonSerializable()
class ResourceContent extends Equatable {
  /// The URI of the resource
  final String uri;

  /// The text content of the resource
  final String text;

  /// Optional MIME type of the content
  final String? mimeType;

  const ResourceContent({required this.uri, required this.text, this.mimeType});

  /// Create a resource content from a JSON map
  factory ResourceContent.fromJson(Map<String, dynamic> json) =>
      _$ResourceContentFromJson(json);

  /// Convert the resource content to a JSON map
  Map<String, dynamic> toJson() => _$ResourceContentToJson(this);

  @override
  List<Object?> get props => [uri, text, mimeType];
}

/// Information about a resource
@JsonSerializable()
class ResourceInfo extends Equatable {
  /// The name of the resource
  final String name;

  /// The URI template for the resource
  final String uriTemplate;

  /// Optional description of the resource
  final String? description;

  const ResourceInfo({
    required this.name,
    required this.uriTemplate,
    this.description,
  });

  /// Create resource info from a JSON map
  factory ResourceInfo.fromJson(Map<String, dynamic> json) =>
      _$ResourceInfoFromJson(json);

  /// Convert resource info to a JSON map
  Map<String, dynamic> toJson() => _$ResourceInfoToJson(this);

  @override
  List<Object?> get props => [name, uriTemplate, description];
}

/// List resources request
class ListResourcesRequest {
  /// The request ID
  final String id;

  /// Create a list resources request
  const ListResourcesRequest({required this.id});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(method: 'listResources', id: id);
  }
}

/// List resources response result
@JsonSerializable()
class ListResourcesResult extends Equatable {
  /// The list of available resources
  final List<ResourceInfo> resources;

  const ListResourcesResult({required this.resources});

  /// Create list resources result from a JSON map
  factory ListResourcesResult.fromJson(Map<String, dynamic> json) =>
      _$ListResourcesResultFromJson(json);

  /// Convert list resources result to a JSON map
  Map<String, dynamic> toJson() => _$ListResourcesResultToJson(this);

  @override
  List<Object?> get props => [resources];
}

/// List resources response
class ListResourcesResponse {
  /// The response ID
  final String id;

  /// The list resources result
  final ListResourcesResult result;

  /// Create a list resources response
  const ListResourcesResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory ListResourcesResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = ListResourcesResult.fromJson(response.result!);
    return ListResourcesResponse(id: response.id, result: result);
  }
}

/// Read resource request parameters
@JsonSerializable()
class ReadResourceParams extends Equatable {
  /// The URI of the resource to read
  final String uri;

  const ReadResourceParams({required this.uri});

  /// Create read resource params from a JSON map
  factory ReadResourceParams.fromJson(Map<String, dynamic> json) =>
      _$ReadResourceParamsFromJson(json);

  /// Convert read resource params to a JSON map
  Map<String, dynamic> toJson() => _$ReadResourceParamsToJson(this);

  @override
  List<Object?> get props => [uri];
}

/// Read resource request
class ReadResourceRequest {
  /// The request ID
  final String id;

  /// The read resource parameters
  final ReadResourceParams params;

  /// Create a read resource request
  const ReadResourceRequest({required this.id, required this.params});

  /// Convert to a McpRequestImpl
  McpRequestImpl toRequest() {
    return McpRequestImpl(
      method: 'readResource',
      id: id,
      params: params.toJson(),
    );
  }
}

/// Read resource response result
@JsonSerializable()
class ReadResourceResult extends Equatable {
  /// The contents of the resource
  final List<ResourceContent> contents;

  const ReadResourceResult({required this.contents});

  /// Create read resource result from a JSON map
  factory ReadResourceResult.fromJson(Map<String, dynamic> json) =>
      _$ReadResourceResultFromJson(json);

  /// Convert read resource result to a JSON map
  Map<String, dynamic> toJson() => _$ReadResourceResultToJson(this);

  @override
  List<Object?> get props => [contents];
}

/// Read resource response
class ReadResourceResponse {
  /// The response ID
  final String id;

  /// The read resource result
  final ReadResourceResult result;

  /// Create a read resource response
  const ReadResourceResponse({required this.id, required this.result});

  /// Convert to a McpResponseImpl
  McpResponseImpl toResponse() {
    return McpResponseImpl(id: id, result: result.toJson());
  }

  /// Create from a McpResponse
  factory ReadResourceResponse.fromResponse(McpResponse response) {
    if (response.error != null) {
      throw response.error!;
    }

    final result = ReadResourceResult.fromJson(response.result!);
    return ReadResourceResponse(id: response.id, result: result);
  }
}

/// Resource list changed notification parameters
@JsonSerializable()
class ResourceListChangedParams extends Equatable {
  const ResourceListChangedParams();

  /// Create resource list changed params from a JSON map
  factory ResourceListChangedParams.fromJson(Map<String, dynamic> json) =>
      _$ResourceListChangedParamsFromJson(json);

  /// Convert resource list changed params to a JSON map
  Map<String, dynamic> toJson() => _$ResourceListChangedParamsToJson(this);

  @override
  List<Object?> get props => [];
}

/// Resource list changed notification
class ResourceListChangedNotification extends McpNotification {
  ResourceListChangedNotification()
    : super(
        method: 'resourceListChanged',
        params: const ResourceListChangedParams().toJson(),
      );
}
