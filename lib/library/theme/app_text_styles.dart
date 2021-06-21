part of 'theme.dart';

class AppTextStylesLight {
  static final largeTitle = GoogleFonts.ibmPlexSans(
    fontSize: 26,
    height: 32,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title1 = GoogleFonts.ibmPlexSans(
    fontSize: 22,
    height: 26,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title2 = GoogleFonts.ibmPlexSans(
    fontSize: 17,
    height: 22,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final title3 = GoogleFonts.ibmPlexSans(
    fontSize: 15,
    height: 20,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final headline = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    height: 16,
    color: AppColors.black,
    fontWeight: FontWeight.w700,
  );
  static final subheadline = GoogleFonts.ibmPlexSans(
    fontSize: 11,
    height: 14,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final body = GoogleFonts.ibmPlexSans(
    fontSize: 13,
    height: 16,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final callout = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 15,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final footnote = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final caption1 = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
  );
  static final caption2 = GoogleFonts.ibmPlexSans(
    fontSize: 10,
    height: 13,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  );
}

class AppTextStylesDark {
  static final largeTitle = AppTextStylesLight.largeTitle.copyWith();
  static final title1 = AppTextStylesLight.largeTitle.copyWith();
  static final title2 = AppTextStylesLight.largeTitle.copyWith();
  static final title3 = AppTextStylesLight.largeTitle.copyWith();
  static final headline = AppTextStylesLight.largeTitle.copyWith();
  static final subheadline = AppTextStylesLight.largeTitle.copyWith();
  static final body = AppTextStylesLight.largeTitle.copyWith();
  static final callout = AppTextStylesLight.largeTitle.copyWith();
  static final footnote = AppTextStylesLight.largeTitle.copyWith();
  static final caption1 = AppTextStylesLight.largeTitle.copyWith();
  static final caption2 = AppTextStylesLight.largeTitle.copyWith();
}
