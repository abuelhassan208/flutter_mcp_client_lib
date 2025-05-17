// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_concrete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpRequestImpl _$McpRequestImplFromJson(Map<String, dynamic> json) =>
    McpRequestImpl(
      method: json['method'] as String,
      id: json['id'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$McpRequestImplToJson(McpRequestImpl instance) =>
    <String, dynamic>{
      'method': instance.method,
      'id': instance.id,
      'params': instance.params,
    };

McpResponseImpl _$McpResponseImplFromJson(Map<String, dynamic> json) =>
    McpResponseImpl(
      id: json['id'] as String,
      result: json['result'] as Map<String, dynamic>?,
      error:
          json['error'] == null
              ? null
              : McpError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$McpResponseImplToJson(McpResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'result': instance.result,
      'error': instance.error,
    };

McpNotificationImpl _$McpNotificationImplFromJson(Map<String, dynamic> json) =>
    McpNotificationImpl(
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$McpNotificationImplToJson(
  McpNotificationImpl instance,
) => <String, dynamic>{'method': instance.method, 'params': instance.params};
