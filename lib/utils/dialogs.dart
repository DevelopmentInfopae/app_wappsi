import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/config/theme/colors.dart';
import 'package:pos_wappsi/screens/components/buttons.dart';
import 'package:pos_wappsi/screens/components/column_with_padding.dart';
import 'package:pos_wappsi/utils/utils.dart';

import '../config/sizes.dart';
import '../screens/components/spacers.dart';

/// Show app dialogs from anywhere without needing to pass
/// context attribute
class AppDialogs {
  /// Show a generic app dialog with a centered button
  static Future<void> genericConfirmationDialog({
    required String title,
    String resourcePath = 'assets/svg/close_circle.svg',
    String? message,
    VoidCallback? onTap,
    String buttonText = 'Continuar',
  }) async {
    final navigatorKey = GlobalLocator.appNavigator;
    if (navigatorKey.currentContext != null) {
      final responsiveDesign = ResponsiveDesign(navigatorKey.currentContext!);
      await showGeneralDialog(
        context: navigatorKey.currentContext!,
        barrierLabel: 'Barrier',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          final svg = resourcePath.endsWith('.svg');
          final theme = Theme.of(navigatorKey.currentContext!);
          final separator = SizedBox(
            height: responsiveDesign.maxHeightValue(16),
          );
          return Center(
            child: Container(
              width: responsiveDesign.maxWidthValue(350),
              margin: responsiveDesign.appHorizontalPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizes.genericDialogsBorderRadius),
              ),
              child: ColumnWithPadding(
                padding: responsiveDesign.appDialogsPadding,
                children: [
                  SizedBox(
                    height: 50,
                    child: svg
                        ? SvgPicture.asset(resourcePath)
                        : Image.asset(resourcePath),
                  ),
                  separator,
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium,
                  ),
                  separator,
                  if (message != null)
                    Column(
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        separator,
                      ],
                    ),
                  GenericRoundedButton(
                    width: double.infinity,
                    onTap: onTap ?? () => navigatorKey.currentState?.pop(),
                    text: buttonText,
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (_, anim, __, child) {
          Tween<Offset> tween;
          if (anim.status == AnimationStatus.reverse) {
            tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
          } else {
            tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
          }

          return SlideTransition(
            position: tween.animate(anim),
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          );
        },
      );
    }
  }

  /// Show a generic app dialog with a centered button
  static Future<void> genericDialog({
    required Widget widget,
    VoidCallback? onTap,
    String buttonText = 'Aceptar',
    bool includeButton = true,

    /// Padding to use on widget
    EdgeInsets? padding,
  }) async {
    final responsiveDesign = ResponsiveDesign(navigatorKey.currentContext!);
    return genericDialogBase(
      widget: Center(
        child: Container(
          width: responsiveDesign.maxWidthValue(340),
          margin: responsiveDesign.appHorizontalPadding,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(AppSizes.genericDialogsBorderRadius),
          ),
          child: ColumnWithPadding(
            padding: padding ?? responsiveDesign.appDialogsPadding,
            children: [
              widget,
              const SafeSpacer(),
              if (includeButton)
                CustomButtonWithState(
                  width: double.infinity,
                  onTap: onTap ?? () => navigatorKey.currentState?.pop(),
                  text: buttonText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a generic app dialog with a centered button
  static Future<bool?> genericConfirmDialog(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    String buttonTextYes = 'Aceptar',
    String buttonTextNo = 'Cancelar',
  }) async {
    final theme = Theme.of(context);
    return await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 19,
            ),
          ),
          content: subtitle == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(),
                  ),
                ),
          actions: [
            CupertinoDialogAction(
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.success_600,
              ),
              child: Text(
                buttonTextYes,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
            CupertinoDialogAction(
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.danger_700,
              ),
              child: Text(buttonTextNo),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
    );
  }

  /// Show a generic app dialog with a centered button
  static Future<dynamic> genericDialogBase({
    required Widget widget,
  }) async {
    final navigatorKey = GlobalLocator.appNavigator;
    if (navigatorKey.currentContext != null) {
      await showGeneralDialog<dynamic>(
        context: navigatorKey.currentContext!,
        barrierLabel: 'Barrier',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return widget;
        },
        transitionBuilder: (_, anim, __, child) {
          Tween<Offset> tween;
          if (anim.status == AnimationStatus.reverse) {
            tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
          } else {
            tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
          }

          return SlideTransition(
            position: tween.animate(anim),
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          );
        },
      );
    }
  }

  /// Show a generic app dialog with a centered button
  static Future<dynamic> genericBottomSheet({
    required Widget widget,
    double? height,
  }) async {
    final navigatorKey = GlobalLocator.appNavigator;
    if (navigatorKey.currentContext != null) {
      final responsiveDesign = ResponsiveDesign(navigatorKey.currentContext!);
      showModalBottomSheet(
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.bodyContainersRadius),
            topRight: Radius.circular(AppSizes.bodyContainersRadius),
          ),
        ),
        context: navigatorKey.currentContext!,
        builder: (context) {
          return Container(
            width: double.infinity,
            height: height ?? responsiveDesign.screenHeight * 0.8,
            padding: responsiveDesign.appHorizontalPadding,
            child: Column(
              children: [
                Expanded(child: widget),
              ],
            ),
          );
        },
      );
    }
  }

  /// Show a generic app dialog with a centered button
  static Future<dynamic> genericBottomSheetTaller({
    required Widget widget,
    double? height,
  }) async {
    final navigatorKey = GlobalLocator.appNavigator;
    if (navigatorKey.currentContext != null) {
      final responsiveDesign = ResponsiveDesign(navigatorKey.currentContext!);
      showBottomSheet(
        // isDismissible: true,
        // showDragHandle: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.bodyContainersRadius),
            topRight: Radius.circular(AppSizes.bodyContainersRadius),
          ),
        ),
        context: navigatorKey.currentContext!,
        builder: (context) {
          return Container(
            width: double.infinity,
            height: height ?? responsiveDesign.screenHeight * 0.8,
            padding: responsiveDesign.appHorizontalPadding,
            child: Column(
              children: [
                Expanded(child: widget),
              ],
            ),
          );
        },
      );
    }
  }

  /// Show custom snackbar
  static void showCustomSnackBar(
    String text, {
    Color? color,
    IconData? icon,
    Duration? duration,
  }) {
    final context = GlobalLocator.appNavigator.currentContext;
    if (context != null) {
      final responsiveDesign = ResponsiveDesign(context);
      try {
        final colors = Theme.of(context).colorScheme;
        final responsive = responsiveDesign;

        snackBar(
          context,
          duration: duration ?? 2.seconds,
          backgroundColor: color ?? AppColors.success_600,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              const HorizontalSpacer(
                width: 20,
              ),
              Text(
                text,
                style: TextStyle(
                  color: AppColors.getFontColorForBackground(
                    color ?? colors.error,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ).expand(),
            ],
          ).paddingSymmetric(
            horizontal: responsive.width(10),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: responsive.width(30),
            vertical: responsive.safeBottomHeight(50),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      } catch (e) {
        log(e);
      }
    }
  }
}

class _OptionSelection extends StatelessWidget {
  const _OptionSelection({
    required this.theme,
    required this.responsiveD,
    required this.text,
    required this.svgPath,
    required this.onTap,
    required this.width,
  });

  final ThemeData theme;

  final ResponsiveDesign responsiveD;

  final String text;

  final String svgPath;

  final VoidCallback onTap;

  final double width;
  @override
  Widget build(BuildContext context) {
    final responsiveDesign = ResponsiveDesign(navigatorKey.currentContext!);
    return InkWell(
      borderRadius: BorderRadius.circular(
        AppSizes.genericBorderRadius2,
      ),
      onTap: onTap,
      child: Material(
        borderRadius: BorderRadius.circular(
          AppSizes.genericBorderRadius2,
        ),
        elevation: 0.3,
        child: Container(
          width: width,
          padding: EdgeInsets.only(
            left: responsiveDesign.maxHeightValue(20),
            right: responsiveDesign.maxHeightValue(20),
            bottom: responsiveDesign.maxHeightValue(24),
            top: responsiveDesign.maxHeightValue(24),
          ),
          height: responsiveDesign.maxHeightValue(148),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.genericBorderRadius2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: responsiveDesign.maxHeightValue(43),
                height: responsiveDesign.maxHeightValue(43),
              ),
              const SafeSpacer(
                height: 24,
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: FittedBox(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
