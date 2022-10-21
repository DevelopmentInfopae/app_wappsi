import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    Key? key,
    this.height,
    required this.width,
    required this.image,
    required this.fit,
  }) : super(key: key);

  final double width;
  final String image;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: width,
      height: height,
      child: Image.asset(
        image,
        fit: fit,
      ),
    );
  }
}
