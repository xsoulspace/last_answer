// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseError _$SupabaseErrorFromJson(Map<String, dynamic> json) =>
    SupabaseError(
      error: json['error'] as String,
      errorDescription: json['error_description'] as String,
    );

Map<String, dynamic> _$SupabaseErrorToJson(SupabaseError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'error_description': instance.errorDescription,
    };
