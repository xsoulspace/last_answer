import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:mocktail/mocktail.dart';

void setupAbstractions(List<VoidCallback> callbacks) {
  setUpAll(() {
    for (final callback in callbacks) {
      callback();
    }
  });
}

void setupIdeaProjectMockTypes() {
  registerFallbackValue(MockIdeaProjectAnswer());
  registerFallbackValue(MockIdeaProjectQuestion());
  registerFallbackValue(MockIdeaProject());
}

void setupNoteProjectMockTypes() {
  registerFallbackValue(MockNoteProject());
}

void setupStoryProjectMockTypes() {
  registerFallbackValue(MockStoryProject());
}
