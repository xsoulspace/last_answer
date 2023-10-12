// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'package:lastanswer/generated/intl/messages_en.dart' as messages_en;
import 'package:lastanswer/generated/intl/messages_it.dart' as messages_it;
import 'package:lastanswer/generated/intl/messages_ru.dart' as messages_ru;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'en': () => new SynchronousFuture(null),
  'it': () => new SynchronousFuture(null),
  'ru': () => new SynchronousFuture(null),
};

MessageLookupByLibrary? _findExact(final String localeName) {
  switch (localeName) {
    case 'en':
      return messages_en.messages;
    case 'it':
      return messages_it.messages;
    case 'ru':
      return messages_ru.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(final String localeName) {
  final availableLocale = Intl.verifiedLocale(
      localeName, (final locale) => _deferredLibraries[locale] != null,
      onFailure: (final _) => null,);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  final lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(CompositeMessageLookup.new);
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(final String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(final String locale) {
  final actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (final _) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
