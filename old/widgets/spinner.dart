import 'package:flutter/material.dart';
import 'package:lastanswer/library/palette.dart';

const spinner = Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Palette.primary),
  ),
);
