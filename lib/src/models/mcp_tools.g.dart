// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_tools.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolArgument _$ToolArgumentFromJson(Map<String, dynamic> json) => ToolArgument(
  name: json['name'] as String,
  description: json['description'] as String?,
  required: json['required'] as bool,
  schema: json['schema'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ToolArgumentToJson(ToolArgument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
      'schema': instance.schema,
    };

ToolInfo _$ToolInfoFromJson(Map<String, dynamic> json) => ToolInfo(
  name: json['name'] as String,
  description: json['description'] as String?,
  arguments:
      (json['arguments'] as List<dynamic>)
          .map((e) => ToolArgument.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ToolInfoToJson(ToolInfo instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'arguments': instance.arguments,
};

ListToolsResult _$ListToolsResultFromJson(Map<String, dynamic> json) =>
    ListToolsResult(
      tools:
          (json['tools'] as List<dynamic>)
              .map((e) => ToolInfo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ListToolsResultToJson(ListToolsResult instance) =>
    <String, dynamic>{'tools': instance.tools};

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) => ContentItem(
  type: $enumDecode(_$ContentTypeEnumMap, json['type']),
  text: json['text'] as String,
);

Map<String, dynamic> _$ContentItemToJson(ContentItem instance) =>
    <String, dynamic>{
      'type': _$ContentTypeEnumMap[instance.type]!,
      'text': instance.text,
    };

const _$ContentTypeEnumMap = {
  ContentType.text: 'text',
  ContentType.markdown: 'markdown',
  ContentType.html: 'html',
  ContentType.json: 'json',
};

CallToolParams _$CallToolParamsFromJson(Map<String, dynamic> json) =>
    CallToolParams(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CallToolParamsToJson(CallToolParams instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

CallToolResult _$CallToolResultFromJson(Map<String, dynamic> json) =>
    CallToolResult(
      content:
          (json['content'] as List<dynamic>)
              .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      isError: json['isError'] as bool?,
    );

Map<String, dynamic> _$CallToolResultToJson(CallToolResult instance) =>
    <String, dynamic>{'content': instance.content, 'isError': instance.isError};

ToolListChangedParams _$ToolListChangedParamsFromJson(
  Map<String, dynamic> json,
) => ToolListChangedParams();

Map<String, dynamic> _$ToolListChangedParamsToJson(
  ToolListChangedParams instance,
) => <String, dynamic>{};
