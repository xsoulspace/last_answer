part of theme;

class AppTextStylesLight {
  AppTextStylesLight._();
  static final largeTitle = GoogleFonts.ibmPlexSans(
    fontSize: 26,
    height: 32 / 26,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title1 = GoogleFonts.ibmPlexSans(
    fontSize: 22,
    height: 26 / 22,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title2 = GoogleFonts.ibmPlexSans(
    fontSize: 17,
    height: 22 / 17,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title3 = GoogleFonts.ibmPlexSans(
    fontSize: 15,
    height: 20 / 15,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    height: 16 / 13,
    color: AppColors.black,
    fontWeight: FontWeight.w700,
  );
  static final subheadline = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    height: 14 / 11,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final body = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    height: 16 / 13,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final callout = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 15 / 12,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final footnote = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13 / 10,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final caption1 = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13 / 10,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
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
  static final largeTitle = AppTextStylesLight.largeTitle.copyWith(
    color: AppColors.white,
  );
  static final title1 = AppTextStylesLight.title1.copyWith(
    color: AppColors.white,
  );
  static final title2 = AppTextStylesLight.title2.copyWith(
    color: AppColors.white,
  );
  static final title3 = AppTextStylesLight.title3.copyWith(
    color: AppColors.white,
  );
  static final headline = AppTextStylesLight.headline.copyWith(
    color: AppColors.white,
  );
  static final subheadline = AppTextStylesLight.subheadline.copyWith(
    color: AppColors.white,
  );
  static final body = AppTextStylesLight.body.copyWith(
    color: AppColors.white,
  );
  static final callout = AppTextStylesLight.callout.copyWith(
    color: AppColors.white,
  );
  static final footnote = AppTextStylesLight.footnote.copyWith(
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
  bodyText1: AppTextStylesLight.body,
  bodyText2: AppTextStylesLight.body,
  button: AppTextStylesLight.body,
  caption: AppTextStylesLight.caption1,
  headline1: AppTextStylesLight.largeTitle,
  headline2: AppTextStylesLight.title1,
  headline3: AppTextStylesLight.title2,
  headline4: AppTextStylesLight.title3,
  headline5: AppTextStylesLight.headline,
  headline6: AppTextStylesLight.callout,
  overline: AppTextStylesLight.footnote,
  subtitle1: AppTextStylesLight.subheadline,
  subtitle2: AppTextStylesLight.caption2,
);
final darkTextTheme = TextTheme(
  bodyText1: AppTextStylesDark.body,
  bodyText2: AppTextStylesDark.body,
  button: AppTextStylesDark.body,
  caption: AppTextStylesDark.caption1,
  headline1: AppTextStylesDark.largeTitle,
  headline2: AppTextStylesDark.title1,
  headline3: AppTextStylesDark.title2,
  headline4: AppTextStylesDark.title3,
  headline5: AppTextStylesDark.headline,
  headline6: AppTextStylesDark.callout,
  overline: AppTextStylesDark.footnote,
  subtitle1: AppTextStylesDark.subheadline,
  subtitle2: AppTextStylesDark.caption2,
);
