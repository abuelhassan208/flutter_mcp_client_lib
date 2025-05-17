// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpInfo _$McpInfoFromJson(Map<String, dynamic> json) =>
    McpInfo(name: json['name'] as String, version: json['version'] as String);

Map<String, dynamic> _$McpInfoToJson(McpInfo instance) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
};

ResourceCapabilityConfig _$ResourceCapabilityConfigFromJson(
  Map<String, dynamic> json,
) => ResourceCapabilityConfig(
  list: json['list'] as bool?,
  read: json['read'] as bool?,
);

Map<String, dynamic> _$ResourceCapabilityConfigToJson(
  ResourceCapabilityConfig instance,
) => <String, dynamic>{'list': instance.list, 'read': instance.read};

ToolCapabilityConfig _$ToolCapabilityConfigFromJson(
  Map<String, dynamic> json,
) => ToolCapabilityConfig(
  list: json['list'] as bool?,
  call: json['call'] as bool?,
);

Map<String, dynamic> _$ToolCapabilityConfigToJson(
  ToolCapabilityConfig instance,
) => <String, dynamic>{'list': instance.list, 'call': instance.call};

PromptCapabilityConfig _$PromptCapabilityConfigFromJson(
  Map<String, dynamic> json,
) => PromptCapabilityConfig(
  list: json['list'] as bool?,
  get: json['get'] as bool?,
);

Map<String, dynamic> _$PromptCapabilityConfigToJson(
  PromptCapabilityConfig instance,
) => <String, dynamic>{'list': instance.list, 'get': instance.get};

SamplingCapabilityConfig _$SamplingCapabilityConfigFromJson(
  Map<String, dynamic> json,
) => SamplingCapabilityConfig(sample: json['sample'] as bool?);

Map<String, dynamic> _$SamplingCapabilityConfigToJson(
  SamplingCapabilityConfig instance,
) => <String, dynamic>{'sample': instance.sample};

ServerCapabilities _$ServerCapabilitiesFromJson(Map<String, dynamic> json) =>
    ServerCapabilities(
      resources:
          json['resources'] == null
              ? null
              : ResourceCapabilityConfig.fromJson(
                json['resources'] as Map<String, dynamic>,
              ),
      tools:
          json['tools'] == null
              ? null
              : ToolCapabilityConfig.fromJson(
                json['tools'] as Map<String, dynamic>,
              ),
      prompts:
          json['prompts'] == null
              ? null
              : PromptCapabilityConfig.fromJson(
                json['prompts'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ServerCapabilitiesToJson(ServerCapabilities instance) =>
    <String, dynamic>{
      'resources': instance.resources,
      'tools': instance.tools,
      'prompts': instance.prompts,
    };

ClientCapabilities _$ClientCapabilitiesFromJson(Map<String, dynamic> json) =>
    ClientCapabilities(
      sampling:
          json['sampling'] == null
              ? null
              : SamplingCapabilityConfig.fromJson(
                json['sampling'] as Map<String, dynamic>,
              ),
      resources:
          json['resources'] == null
              ? null
              : ResourceCapabilityConfig.fromJson(
                json['resources'] as Map<String, dynamic>,
              ),
      tools:
          json['tools'] == null
              ? null
              : ToolCapabilityConfig.fromJson(
                json['tools'] as Map<String, dynamic>,
              ),
      prompts:
          json['prompts'] == null
              ? null
              : PromptCapabilityConfig.fromJson(
                json['prompts'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ClientCapabilitiesToJson(ClientCapabilities instance) =>
    <String, dynamic>{
      'sampling': instance.sampling,
      'resources': instance.resources,
      'tools': instance.tools,
      'prompts': instance.prompts,
    };

InitializeParams _$InitializeParamsFromJson(Map<String, dynamic> json) =>
    InitializeParams(
      protocolVersion: json['protocolVersion'] as String,
      clientInfo: McpInfo.fromJson(json['clientInfo'] as Map<String, dynamic>),
      capabilities:
          json['capabilities'] == null
              ? null
              : ClientCapabilities.fromJson(
                json['capabilities'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$InitializeParamsToJson(InitializeParams instance) =>
    <String, dynamic>{
      'protocolVersion': instance.protocolVersion,
      'clientInfo': instance.clientInfo,
      'capabilities': instance.capabilities,
    };

InitializeResult _$InitializeResultFromJson(Map<String, dynamic> json) =>
    InitializeResult(
      protocolVersion: json['protocolVersion'] as String,
      serverInfo: McpInfo.fromJson(json['serverInfo'] as Map<String, dynamic>),
      capabilities: ServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InitializeResultToJson(InitializeResult instance) =>
    <String, dynamic>{
      'protocolVersion': instance.protocolVersion,
      'serverInfo': instance.serverInfo,
      'capabilities': instance.capabilities,
    };
