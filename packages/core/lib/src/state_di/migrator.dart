import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/parsers/parsers.dart' as parsers;

Future<void> migrate() async {
  // Use parser library to discover and populate local DB structures.
  await parsers.parseAndPopulate();
}
