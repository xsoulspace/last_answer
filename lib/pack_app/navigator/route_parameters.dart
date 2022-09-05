import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_parameters.g.dart';

@immutable
@JsonSerializable()
class AppRouteParameters {
  const AppRouteParameters({
    this.noteId,
    this.ideaId,
    this.answerId,
  });
  factory AppRouteParameters.fromJson(final Map<String, dynamic> json) =>
      _$AppRouteParametersFromJson(json);
  final String? noteId;
  final String? ideaId;
  final String? answerId;
}
