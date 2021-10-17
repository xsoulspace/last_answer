part of theme;

class AppTextStylesLight {
  AppTextStylesLight._();
  static final headline1 = GoogleFonts.ibmPlexSans(
    fontSize: 26,
    height: 32 / 26,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline2 = GoogleFonts.ibmPlexSans(
    fontSize: 22,
    height: 26 / 22,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline3 = GoogleFonts.ibmPlexSans(
    fontSize: 20,
    height: 22 / 20,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline4 = GoogleFonts.ibmPlexSans(
    fontSize: 19,
    height: 21 / 19,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline5 = GoogleFonts.ibmPlexSans(
    fontSize: 18,
    height: 20 / 18,
    color: AppColors.black,
    fontWeight: FontWeight.w700,
  );
  static final headline6 = GoogleFonts.ibmPlexSans(
    fontSize: 17,
    height: 19 / 17,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final subtitle1 = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    height: 18 / 16,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );

  static final subtitle2 = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 14 / 12,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  );
  static final bodyText1 = bodyText2.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final bodyText2 = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    height: 16 / 16,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final overline = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 15 / 12,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final caption1 = caption2.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final caption2 = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13 / 10,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  );
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
