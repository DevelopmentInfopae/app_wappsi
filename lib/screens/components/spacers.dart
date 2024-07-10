import 'package:flutter/material.dart';
import 'package:pos_wappsi/config/sizes.dart';
import 'package:pos_wappsi/utils/utils.dart';

/// Bottom spacer
///
/// Creates an empty box
class BottomSpacer extends StatelessWidget {
  /// Constructor
  const BottomSpacer({super.key, this.height = 24});

  ///
  final double height;
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.safeBottomHeight(height),
    );
  }
}

/// Bottom navBar spacer
///
/// Creates an empty box with height of the actual 60% BottomNBavigationBar of app
class BottomNavBarSpacer extends StatelessWidget {
  /// Constructor
  const BottomNavBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.maxHeightValue(AppSizes.navBarHeight),
    );
  }
}

/// Bottom spacer
///
/// Creates an empty box
class SafeBottomSpacer extends StatelessWidget {
  /// Constructor
  const SafeBottomSpacer({
    super.key,
    this.height = 24,
  });

  /// Element safe height
  final double height;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.safeBottomHeight(height),
    );
  }
}

/// Generic safe spacer
///
/// Creates an empty box
class SafeSpacer extends StatelessWidget {
  /// Constructor
  const SafeSpacer({
    super.key,
    this.height = 20,
  });

  /// Optional custom height (in px)
  final double height;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.maxHeightValue(height),
    );
  }
}

/// Creates an empty box wit given width
class HorizontalSpacer extends StatelessWidget {
  /// Constructor
  const HorizontalSpacer({
    super.key,
    this.width = 15,
  });

  /// Optional custom height (in design px)
  final double width;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      width: responsive.maxWidthValue(width),
    );
  }
}

/// Header spacer
///
/// Creates an empty box, use on header sections with no safeArea
class HeaderSpacer extends StatelessWidget {
  /// Constructor
  const HeaderSpacer({
    super.key,
    this.height = 40,
  });

  /// Optional custom height (in px)
  final double height;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.safePaddingTop(height),
    );
  }
}

/// ExtendedBodyBottomSpacer
///
/// Creates an empty box, use on scaffolds with ExtendedBody=true
class ExtendedBodyBottomSpacer extends StatelessWidget {
  /// Constructor
  const ExtendedBodyBottomSpacer({
    super.key,
    this.height = 70,
  });

  /// Optional custom height (in px)
  final double height;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return SizedBox(
      height: responsive.safePaddingTop(height),
    );
  }
}
