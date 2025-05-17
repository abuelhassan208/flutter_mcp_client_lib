// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_resources.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceContent _$ResourceContentFromJson(Map<String, dynamic> json) =>
    ResourceContent(
      uri: json['uri'] as String,
      text: json['text'] as String,
      mimeType: json['mimeType'] as String?,
    );

Map<String, dynamic> _$ResourceContentToJson(ResourceContent instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'text': instance.text,
      'mimeType': instance.mimeType,
    };

ResourceInfo _$ResourceInfoFromJson(Map<String, dynamic> json) => ResourceInfo(
  name: json['name'] as String,
  uriTemplate: json['uriTemplate'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ResourceInfoToJson(ResourceInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uriTemplate': instance.uriTemplate,
      'description': instance.description,
    };

ListResourcesResult _$ListResourcesResultFromJson(Map<String, dynamic> json) =>
    ListResourcesResult(
      resources:
          (json['resources'] as List<dynamic>)
              .map((e) => ResourceInfo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ListResourcesResultToJson(
  ListResourcesResult instance,
) => <String, dynamic>{'resources': instance.resources};

ReadResourceParams _$ReadResourceParamsFromJson(Map<String, dynamic> json) =>
    ReadResourceParams(uri: json['uri'] as String);

Map<String, dynamic> _$ReadResourceParamsToJson(ReadResourceParams instance) =>
    <String, dynamic>{'uri': instance.uri};

ReadResourceResult _$ReadResourceResultFromJson(Map<String, dynamic> json) =>
    ReadResourceResult(
      contents:
          (json['contents'] as List<dynamic>)
              .map((e) => ResourceContent.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ReadResourceResultToJson(ReadResourceResult instance) =>
    <String, dynamic>{'contents': instance.contents};

ResourceListChangedParams _$ResourceListChangedParamsFromJson(
  Map<String, dynamic> json,
) => ResourceListChangedParams();

Map<String, dynamic> _$ResourceListChangedParamsToJson(
  ResourceListChangedParams instance,
) => <String, dynamic>{};
