// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpError _$McpErrorFromJson(Map<String, dynamic> json) => McpError(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$McpErrorToJson(McpError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
