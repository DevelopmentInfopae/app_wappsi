import 'package:flutter/material.dart';
import 'package:pos_wappsi/constant.dart';

/// Custom Single Child Scroll View that uses default physics for app
class CustomSingleChildScrollView extends StatelessWidget {
  const CustomSingleChildScrollView({
    super.key,
    required this.child,
    this.physics,
  });

  final Widget child;

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: child,
      physics: physics ?? AppConstants.scrollPhysics,
    );
  }
}
