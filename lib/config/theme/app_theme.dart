import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_wappsi/config/theme/colors.dart';

/// App theme.
///
/// Class used to manage theme data on app.
ThemeData globalTheme() {
  TextTheme globalTextTheme(TextTheme textTheme) {
    return textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 40,
        color: const Color(0xff323231),
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: const Color(0xff323231),
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 24.0,
        color: const Color(0xff323231),
      ),
      displayLarge: textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 55.0,
        color: const Color(0xff323231),
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: const Color(0xff323231),
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 10.0,
        color: const Color(0xff323231),
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 55.0,
        color: const Color(0xff323231),
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: const Color(0xff323231),
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        color: const Color(0xff323231),
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
        color: const Color(0xff323231),
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 10.0,
        color: const Color(0xff323231),
      ),
    );
  }

  /// Take defined colors from design.
  ColorScheme colorSchemeTheme(ColorScheme themeColor) {
    return themeColor.copyWith(
      primary: AppColors.primary_300,
      inversePrimary: AppColors.primary_300,
      primaryContainer: AppColors.primary_200,
      outline: AppColors.primary_300,
      secondary: const Color(0xff323231),
      onSecondary: const Color(0xffFBFBFB),
      onPrimary: const Color(0xffEBF1FF),
      tertiary: const Color(0xff323231),
      onTertiaryContainer: const Color(0xffD9DBD8),
      onPrimaryContainer: AppColors.primary_50,
      surface: Colors.white,
      error: AppColors.danger_700,
      onError: Colors.white,
    );
  }

  ButtonThemeData buttonThemeData(ButtonThemeData themeButtonTheme) {
    return themeButtonTheme.copyWith(
      buttonColor: AppColors.primary_300,
      disabledColor: AppColors.secondary_300,
    );
  }

  SliderThemeData sliderThemeData(SliderThemeData sliderThemeData) {
    return sliderThemeData.copyWith(
      activeTrackColor: const Color.fromRGBO(255, 255, 255, 1),
      thumbColor: const Color.fromRGBO(72, 104, 126, 1),
      inactiveTrackColor: const Color.fromRGBO(72, 104, 126, 1),
    );
  }

  InputDecorationTheme inputDecorationTheme(InputDecorationTheme theme) {
    final border = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: AppColors.primary_300,
        width: 0.3,
      ),
    );
    final focusedBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: AppColors.primary_300,
        width: 0.3,
      ),
    );
    final errorBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xffaa3030),
        width: 1,
      ),
    );
    // const outlineBorder = BorderSide.none;
    return theme.copyWith(
      border: border,
      focusedBorder: focusedBorder,
      enabledBorder: border,
      errorBorder: errorBorder,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      alignLabelWithHint: true,
      labelStyle: theme.labelStyle?.copyWith(
        fontFamily: 'Goldplay',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      floatingLabelStyle: theme.labelStyle?.copyWith(
        fontFamily: 'Goldplay',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
      errorStyle: theme.labelStyle?.copyWith(
        fontFamily: 'Goldplay',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: AppColors.danger_400,
      ),
      hintStyle: theme.labelStyle?.copyWith(
        fontFamily: 'Goldplay',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: const Color(0xff323231),
      ),
    );
  }

  CheckboxThemeData checkboxThemeData(CheckboxThemeData checkboxThemeData) {
    return checkboxThemeData.copyWith(
      fillColor: MaterialStateProperty.all<Color>(
        const Color(0xff176AFC),
      ),
    );
  }

  BottomNavigationBarThemeData bottomBarThemeData(
    BottomNavigationBarThemeData bottomNavBarThemeData,
  ) {
    return bottomNavBarThemeData.copyWith(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xff323231),
      unselectedItemColor: const Color(0xffE0DFE0),
      selectedLabelStyle: bottomNavBarThemeData.selectedLabelStyle?.copyWith(
        fontFamily: 'Goldplay',
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        color: const Color(0xff323231),
      ),
      selectedIconTheme: bottomNavBarThemeData.selectedIconTheme?.copyWith(
        color: const Color(0xff323231),
      ),
      unselectedIconTheme: bottomNavBarThemeData.unselectedIconTheme?.copyWith(
        color: const Color(0xffE0DFE0),
      ),
    );
  }

  ListTileThemeData listTileThemeData(
    ListTileThemeData listTileThemeData,
  ) {
    return listTileThemeData.copyWith(iconColor: AppColors.primary_300);
  }

  final ThemeData theme = ThemeData.light();

  return theme.copyWith(
    primaryColor: AppColors.primary_400,
    shadowColor: Colors.grey,
    sliderTheme: sliderThemeData(theme.sliderTheme),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: globalTextTheme(
      GoogleFonts.poppinsTextTheme(
        theme.textTheme,
      ),
    ),
    buttonTheme: buttonThemeData(theme.buttonTheme),
    checkboxTheme: checkboxThemeData(theme.checkboxTheme),
    inputDecorationTheme: inputDecorationTheme(theme.inputDecorationTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      color: Colors.transparent,
      iconTheme: IconThemeData(
        color: Color.fromRGBO(255, 255, 255, 1),
        size: 24.0,
      ),
    ),
    bottomNavigationBarTheme: bottomBarThemeData(
      theme.bottomNavigationBarTheme,
    ),
    listTileTheme: listTileThemeData(theme.listTileTheme),
    colorScheme: colorSchemeTheme(theme.colorScheme)
        .copyWith(surface: AppColors.background),
  );
}
