// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_prompts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptArgument _$PromptArgumentFromJson(Map<String, dynamic> json) =>
    PromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool,
      schema: json['schema'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PromptArgumentToJson(PromptArgument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
      'schema': instance.schema,
    };

PromptInfo _$PromptInfoFromJson(Map<String, dynamic> json) => PromptInfo(
  name: json['name'] as String,
  description: json['description'] as String?,
  arguments:
      (json['arguments'] as List<dynamic>)
          .map((e) => PromptArgument.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PromptInfoToJson(PromptInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'arguments': instance.arguments,
    };

ListPromptsResult _$ListPromptsResultFromJson(Map<String, dynamic> json) =>
    ListPromptsResult(
      prompts:
          (json['prompts'] as List<dynamic>)
              .map((e) => PromptInfo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ListPromptsResultToJson(ListPromptsResult instance) =>
    <String, dynamic>{'prompts': instance.prompts};

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    MessageContent(type: json['type'] as String, text: json['text'] as String);

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{'type': instance.type, 'text': instance.text};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: MessageContent.fromJson(json['content'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': _$MessageRoleEnumMap[instance.role]!,
  'content': instance.content,
};

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

GetPromptParams _$GetPromptParamsFromJson(Map<String, dynamic> json) =>
    GetPromptParams(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GetPromptParamsToJson(GetPromptParams instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

GetPromptResult _$GetPromptResultFromJson(Map<String, dynamic> json) =>
    GetPromptResult(
      description: json['description'] as String?,
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$GetPromptResultToJson(GetPromptResult instance) =>
    <String, dynamic>{
      'description': instance.description,
      'messages': instance.messages,
    };

PromptListChangedParams _$PromptListChangedParamsFromJson(
  Map<String, dynamic> json,
) => PromptListChangedParams();

Map<String, dynamic> _$PromptListChangedParamsToJson(
  PromptListChangedParams instance,
) => <String, dynamic>{};
