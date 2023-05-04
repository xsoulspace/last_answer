import 'package:flutter/material.dart';
import 'package:lastanswer/library/theme/app_colors.dart';

const lightColorScheme = ColorScheme(
  primary: AppColors.black,
  secondary: AppColors.primary,
  surface: AppColors.cleanWhite,
  background: AppColors.white,
  error: AppColors.accent1,
  onPrimary: AppColors.grey1,
  onSecondary: AppColors.grey4,
  onSurface: AppColors.cleanWhite,
  onBackground: AppColors.white,
  onError: AppColors.accent2,
  brightness: Brightness.light,
);

const darkColorScheme = ColorScheme(
  primary: AppColors.white,
  secondary: AppColors.primary,
  surface: AppColors.black,
  background: AppColors.black,
  error: AppColors.accent1,
  onPrimary: AppColors.cleanWhite,
  onSecondary: AppColors.primary,
  onSurface: AppColors.black,
  onBackground: AppColors.black,
  onError: AppColors.accent2,
  brightness: Brightness.dark,
);
