import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastanswer/library/theme/app_colors.dart';

class AppTextStylesLight {
  AppTextStylesLight._();
  static final headline1 = GoogleFonts.notoSans(
    fontSize: 26,
    height: 32 / 26,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );
  static final headline1Strut = StrutStyle.fromTextStyle(headline1);

  static final headline2 = GoogleFonts.notoSans(
    fontSize: 22,
    height: 28 / 22,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final headline2Strut = StrutStyle.fromTextStyle(headline2);

  static final headline3 = GoogleFonts.notoSans(
    fontSize: 20,
    height: 26 / 20,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );
  static final headline3Strut = StrutStyle.fromTextStyle(headline3);

  static final headline4 = GoogleFonts.notoSans(
    fontSize: 19,
    height: 25 / 19,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );
  static final headline4Strut = StrutStyle.fromTextStyle(headline4);

  static final headline5 = GoogleFonts.notoSans(
    fontSize: 18,
    height: 24 / 18,
    color: AppColors.black,
    fontWeight: FontWeight.w700,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final headline5Strut = StrutStyle.fromTextStyle(headline5);

  static final headline6 = GoogleFonts.notoSans(
    fontSize: 17,
    height: 23 / 17,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final headline6Strut = StrutStyle.fromTextStyle(headline6);

  static final subtitle1 = GoogleFonts.notoSans(
    fontSize: 16,
    height: 18 / 16,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final subtitle1Strut = StrutStyle.fromTextStyle(subtitle1);

  static final subtitle2 = GoogleFonts.notoSans(
    fontSize: 12,
    height: 14 / 12,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final subtitle2Strut = StrutStyle.fromTextStyle(subtitle2);

  static final bodyText1 = bodyText2
      .copyWith(
    fontWeight: FontWeight.bold,
  )
      .copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final bodyText1Strut = StrutStyle.fromTextStyle(bodyText1);

  static final bodyText2 = GoogleFonts.notoSans(
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final bodyText2Strut = StrutStyle.fromTextStyle(bodyText2);

  static final overline = GoogleFonts.notoSans(
    fontSize: 12,
    height: 15 / 12,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final overlineStrut = StrutStyle.fromTextStyle(overline);

  static final caption1 = caption2
      .copyWith(
    fontWeight: FontWeight.bold,
  )
      .copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final caption1Strut = StrutStyle.fromTextStyle(caption1);

  static final caption2 = GoogleFonts.notoSans(
    fontSize: 10,
    height: 13 / 10,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  ).copyWith(
    fontFamilyFallback: ['NotoColorEmoji'],
  );

  static final caption2Strut = StrutStyle.fromTextStyle(caption2);
}

class AppTextStylesDark {
  AppTextStylesDark._();
  static final headline1 = AppTextStylesLight.headline1.copyWith(
    color: AppColors.white,
  );
  static final headline2 = AppTextStylesLight.headline2.copyWith(
    color: AppColors.white,
  );
  static final headline3 = AppTextStylesLight.headline3.copyWith(
    color: AppColors.white,
  );
  static final headline4 = AppTextStylesLight.headline4.copyWith(
    color: AppColors.white,
  );
  static final headline5 = AppTextStylesLight.headline5.copyWith(
    color: AppColors.white,
  );
  static final subtitle1 = AppTextStylesLight.subtitle1.copyWith(
    color: AppColors.white,
  );
  static final subtitle2 = AppTextStylesLight.subtitle2.copyWith(
    color: AppColors.white,
  );
  static final bodyText1 = AppTextStylesLight.bodyText1.copyWith(
    color: AppColors.white,
  );
  static final bodyText2 = AppTextStylesLight.bodyText2.copyWith(
    color: AppColors.white,
  );
  static final overline = AppTextStylesLight.overline.copyWith(
    color: AppColors.white,
  );
  static final headline6 = AppTextStylesLight.headline6.copyWith(
    color: AppColors.white,
  );
  static final caption1 = AppTextStylesLight.caption1.copyWith(
    color: AppColors.white,
  );
  static final caption2 = AppTextStylesLight.caption2.copyWith(
    color: AppColors.white,
  );
}

final lightTextTheme = TextTheme(
  bodyText1: AppTextStylesLight.bodyText1,
  bodyText2: AppTextStylesLight.bodyText2,
  button: AppTextStylesLight.bodyText2,
  caption: AppTextStylesLight.caption2,
  headline1: AppTextStylesLight.headline1,
  headline2: AppTextStylesLight.headline2,
  headline3: AppTextStylesLight.headline3,
  headline4: AppTextStylesLight.headline4,
  headline5: AppTextStylesLight.headline5,
  headline6: AppTextStylesLight.headline6,
  overline: AppTextStylesLight.overline,
  subtitle1: AppTextStylesLight.subtitle1,
  subtitle2: AppTextStylesLight.subtitle2,
);
final darkTextTheme = TextTheme(
  bodyText1: AppTextStylesDark.bodyText1,
  bodyText2: AppTextStylesDark.bodyText2,
  button: AppTextStylesDark.bodyText2,
  caption: AppTextStylesDark.caption2,
  headline1: AppTextStylesDark.headline1,
  headline2: AppTextStylesDark.headline2,
  headline3: AppTextStylesDark.headline3,
  headline4: AppTextStylesDark.headline4,
  headline5: AppTextStylesDark.headline5,
  headline6: AppTextStylesDark.headline6,
  overline: AppTextStylesDark.overline,
  subtitle1: AppTextStylesDark.subtitle1,
  subtitle2: AppTextStylesDark.subtitle2,
);
