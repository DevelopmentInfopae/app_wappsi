import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_wappsi/config/sizes.dart';
import 'package:pos_wappsi/screens/components/column_with_padding.dart';
import 'package:pos_wappsi/screens/components/icon_buttons.dart';
import 'package:pos_wappsi/screens/components/spacers.dart';

/// AppBar used commonly on app screens
class CustomAppBar extends StatelessWidget {
  /// Constructor
  const CustomAppBar({
    super.key,
    this.action,
    this.onBack,
    this.title,
    this.centerTitle = false,
    this.padding = false,
    this.includeBottomSpacer = true,
    this.titleIcon,
    this.prefix,
    this.includeBackArrow = true,
  });

  /// AppBar actions
  final Widget? action;

  /// AppBar actions
  final Widget? titleIcon;

  /// AppBar actions
  final Widget? prefix;

  /// Callback on back
  final VoidCallback? onBack;

  /// AppBar tittle
  final String? title;

  /// Center title on appBar
  final bool centerTitle;

  /// Include back arrow or not
  final bool includeBackArrow;

  /// include bottom SafeSpacer
  final bool includeBottomSpacer;

  /// To add or not app horizontal padding
  final bool padding;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark,
    );
    final theme = Theme.of(context);
    final children = [
      const HeaderSpacer(),
      Row(
        mainAxisAlignment: centerTitle
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          prefix ??
              (includeBackArrow
                  ? CustomIconButton(
                      size: 24,
                      icon: Icons.arrow_back_rounded,
                      onTap: onBack ??
                          () =>
                              onBack ??
                              () => Navigator.of(context).canPop()
                                  ? Navigator.of(context).canPop()
                                  : null,
                    )
                  : const SizedBox(
                      width: 28,
                    )),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HorizontalSpacer(
                  width: 4,
                ),
                Row(
                  children: [
                    if (titleIcon != null) titleIcon!,
                    if (titleIcon != null)
                      const HorizontalSpacer(
                        width: 8,
                      ),
                    if (title != null)
                      Text(
                        title!.toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 26,
                        ),
                      ),
                  ],
                ),
                const HorizontalSpacer(
                  width: 4,
                ),
              ],
            ),
          ),
          if (action != null) action!,
          if (centerTitle && action == null)
            const SizedBox(
              width: 28,
            ),
        ],
      ),
      if (includeBottomSpacer)
        const SafeSpacer(
          height: 16,
        ),
    ];
    if (padding) return ColumnWithPadding(children: children);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// AppBar used commonly on app screens
class CustomAppBar2 extends StatelessWidget {
  /// Constructor
  const CustomAppBar2({
    super.key,
    this.action,
    this.onBack,
    this.title,
    this.subtitle,
    this.padding = false,
    this.includeBottomSpacer = true,
    this.titleIcon,
    this.prefix,
    this.onTop = true,
    this.includeBackArrow = true,
  });

  /// AppBar actions
  final Widget? action;

  /// AppBar actions
  final Widget? titleIcon;

  /// AppBar actions
  final Widget? prefix;

  /// Callback on back
  final VoidCallback? onBack;

  /// AppBar tittle
  final String? title;

  /// AppBar subtitle
  final String? subtitle;

  /// Include back arrow or not
  final bool includeBackArrow;

  /// include bottom SafeSpacer
  final bool includeBottomSpacer;

  /// To add or not app horizontal padding
  final bool padding;

  /// To add or not app horizontal padding
  final bool onTop;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark,
    );
    final theme = Theme.of(context);
    final children = [
      if (onTop) const HeaderSpacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          prefix ??
              InkWell(
                onTap: onBack ??
                    () => Navigator.of(context).canPop()
                        ? Navigator.of(context).canPop()
                        : null,
                child: Icon(
                  Navigator.of(context).canPop()
                      ? Icons.arrow_back_rounded
                      : Icons.close_rounded,
                  size: AppSizes.appBarIcons,
                ),
              ),
          action ?? const SizedBox(),
        ],
      ),
      const SafeSpacer(
        height: 8,
      ),
      Row(
        children: [
          if (titleIcon != null) titleIcon!,
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      if (subtitle != null)
        Text(
          subtitle!,
          style: theme.textTheme.bodyLarge?.copyWith(),
        ),
      if (includeBottomSpacer)
        const SafeSpacer(
          height: 16,
        ),
    ];
    if (padding) {
      return ColumnWithPadding(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
