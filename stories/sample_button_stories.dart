// ignore_for_file:avoid-returning-widgets
import 'package:flutter/material.dart';

import 'sample_button.dart';

Widget primary() => const Button(
      text: 'Button',
      style: ButtonStyles.primary,
    );

Widget secondary() => const Button(
      text: 'Button',
      style: ButtonStyles.secondary,
    );

Widget disabled() => const Button(
      text: 'Button',
      style: ButtonStyles.disabled,
    );
