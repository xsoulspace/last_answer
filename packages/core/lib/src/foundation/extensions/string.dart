import 'package:form_builder_validators/form_builder_validators.dart';

extension CoreStringExtension on String {
  bool get isEmail => FormBuilderValidators.email()(this) == null;
}
