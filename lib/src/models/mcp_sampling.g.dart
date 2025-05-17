// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_sampling.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleParams _$SampleParamsFromJson(Map<String, dynamic> json) => SampleParams(
  messages:
      (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
  options: json['options'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SampleParamsToJson(SampleParams instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'options': instance.options,
    };

SampleResult _$SampleResultFromJson(Map<String, dynamic> json) => SampleResult(
  message: Message.fromJson(json['message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SampleResultToJson(SampleResult instance) =>
    <String, dynamic>{'message': instance.message};
