// ignore_for_file: avoid_annotating_with_dynamic

import 'package:flutter/foundation.dart';

// ignore: long-parameter-list
String convertErrorDetailsToString(
  final dynamic exception,
  final StackTrace? stack, {
  final dynamic reason,
  final Iterable<DiagnosticsNode> information = const [],
  final bool fatal = false,
  final bool? printDetails,
}) {
  final errorDetails = StringBuffer();
  final String info = information.isEmpty
      ? ''
      : (StringBuffer()..writeAll(information, '\n')).toString();

  errorDetails
    ..writeln('----------------ANALYTICS CRASH----------------')
    ..writeln('----------------${DateTime.now()}----------------');
  if (fatal) {
    errorDetails.writeln('----------------FATAL----------------');
  }
  // If available, give a reason to the exception.
  if (reason != null) {
    errorDetails.writeln('The following exception was thrown $reason:');
  }

  // Need to print the exception to explain why the exception was thrown.
  errorDetails.writeln(exception.toString());

  // Print information provided by the Flutter framework about the exception

  if (info.isNotEmpty) errorDetails.writeln(info);

  // Not using Trace.format here to stick to the default stack trace format
  // that Flutter developers are used to seeing.

  if (stack != null) errorDetails.writeln('\n$stack');

  errorDetails.writeln('----------------------------------------------------');

  return errorDetails.toString();
}
