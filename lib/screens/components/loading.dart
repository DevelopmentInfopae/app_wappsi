import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_wappsi/utils/utils.dart';

/// Sized custom progress indicator
class SizedCustomProgressIndicator extends StatelessWidget {
  /// Constructor
  const SizedCustomProgressIndicator({
    super.key,
    this.size = 25,
    this.headRadius = 2.5,
    this.strokeWidth = 2,
    this.color,
    this.value,
  });

  /// Widget size (h and w)
  final double size;

  /// Progress indicator stroke width
  final double strokeWidth;

  /// Progress indicator head radius
  final double headRadius;

  /// Optional color to apply on
  final Color? color;

  final double? value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CustomCircularProgressIndicator(
          strokeWidth: strokeWidth,
          headRadius: headRadius,
          color: color,
          value: value,
        ),
      ),
    );
  }
}

/// It's equal to [SizedCustomProgressIndicator] but with background
class SizedCustomProgressIndicator2 extends StatelessWidget {
  /// Constructor
  const SizedCustomProgressIndicator2({
    super.key,
    this.size = 25,
    this.value,
    this.headRadius = 2.5,
    this.strokeWidth = 2,
    this.color,
  });

  /// Widget size (h and w)
  final double size;

  final double? value;

  /// Progress indicator stroke width
  final double strokeWidth;

  /// Progress indicator head radius
  final double headRadius;

  /// Optional color to apply on
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(6.0),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
      ),
      child: SizedCustomProgressIndicator(
        color: color,
        headRadius: headRadius,
        size: size,
        key: key,
        strokeWidth: strokeWidth,
        value: value,
      ),
    );
  }
}

const int _kIndeterminateCircularDuration = 1333 * 2222;

/// Custom implementation of Circular Progress indicator
class CustomCircularProgressIndicator extends ProgressIndicator {
  /// Creates a circular progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const CustomCircularProgressIndicator({
    super.key,
    super.value,
    super.backgroundColor,
    super.color,
    super.valueColor,
    this.strokeWidth = 4.0,
    super.semanticsLabel,
    super.semanticsValue,
    this.headRadius = 5,
  });

  /// The width of the line used to draw the circle.
  final double strokeWidth;

  /// The head radius.
  final double headRadius;

  @override
  State<CustomCircularProgressIndicator> createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  static const int _pathCount = _kIndeterminateCircularDuration ~/ 1333;
  static const int _rotationCount = _kIndeterminateCircularDuration ~/ 2222;

  static final Animatable<double> _strokeHeadTween = CurveTween(
    curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
  ).chain(
    CurveTween(
      curve: const SawTooth(_pathCount),
    ),
  );
  static final Animatable<double> _strokeTailTween = CurveTween(
    curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
  ).chain(
    CurveTween(
      curve: const SawTooth(_pathCount),
    ),
  );
  static final Animatable<double> _offsetTween =
      CurveTween(curve: const SawTooth(_pathCount));
  static final Animatable<double> _rotationTween =
      CurveTween(curve: const SawTooth(_rotationCount));

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateCircularDuration),
      vsync: this,
    );
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMaterialIndicator(
    BuildContext context,
    double headValue,
    double tailValue,
    double offsetValue,
    double rotationValue,
  ) {
    final Color? trackColor = widget.backgroundColor ??
        ProgressIndicatorTheme.of(context).circularTrackColor;
    final responsive = ResponsiveDesign(context);

    return _buildSemanticsWrapper(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          minWidth: responsive.height(225),
          minHeight: responsive.height(225),
        ),
        child: CustomPaint(
          painter: _CircularProgressIndicatorPainter(
            headRadius: widget.headRadius,
            backgroundColor: trackColor,
            valueColor: _getValueColor(context),
            value: widget.value, // may be null
            headValue:
                headValue, // remaining arguments are ignored if widget.value is not null
            tailValue: tailValue,
            offsetValue: offsetValue,
            rotationValue: rotationValue,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildSemanticsWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    return Semantics(
      child: child,
    );
  }

  Color _getValueColor(BuildContext context) {
    return widget.color ??
        ProgressIndicatorTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
  }

  Widget _buildAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return _buildMaterialIndicator(
          context,
          _strokeHeadTween.evaluate(_controller),
          _strokeTailTween.evaluate(_controller),
          _offsetTween.evaluate(_controller),
          _rotationTween.evaluate(_controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAnimation();
  }
}

class _CircularProgressIndicatorPainter extends CustomPainter {
  _CircularProgressIndicatorPainter({
    this.backgroundColor,
    required this.valueColor,
    required this.value,
    required this.headValue,
    required this.tailValue,
    required this.offsetValue,
    required this.rotationValue,
    required this.strokeWidth,
    this.headRadius = 5,
  })  : arcStart = value != null
            ? _startAngle
            : _startAngle +
                tailValue * 3 / 2 * math.pi +
                rotationValue * math.pi * 2.0 +
                offsetValue * 0.5 * math.pi,
        arcSweep = value != null
            ? clampDouble(value, 0.0, 1.0) * _sweep
            : math.max(
                headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
                _epsilon,
              );

  /// The head radius.
  final double headRadius;
  final Color? backgroundColor;
  final Color valueColor;
  final double? value;
  final double headValue;
  final double tailValue;
  final double offsetValue;
  final double rotationValue;
  final double strokeWidth;
  final double arcStart;
  final double arcSweep;

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Paint circlePaint = Paint()
      ..color = valueColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    if (backgroundColor != null) {
      final Paint backgroundPaint = Paint()
        ..color = backgroundColor!
        ..strokeWidth = strokeWidth / 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Offset.zero & size,
        arcStart + arcSweep + (0.017 * math.pi),
        _sweep - (0.03 * math.pi),
        false,
        backgroundPaint,
      );
    }

    if (value == null) {
      // Indeterminate
      paint.strokeCap = StrokeCap.square;
    }
    final radius = size.shortestSide / 2;
    canvas.drawArc(
      Offset.zero & size,
      arcStart,
      arcSweep - 0.07,
      false,
      paint,
    );
    canvas.drawCircle(
      Offset(
        math.cos(arcStart + arcSweep) * (size.height / 2) + radius,
        math.sin(arcStart + arcSweep) * (size.height / 2) + radius,
      ),
      headRadius,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.headValue != headValue ||
        oldPainter.tailValue != tailValue ||
        oldPainter.offsetValue != offsetValue ||
        oldPainter.rotationValue != rotationValue ||
        oldPainter.strokeWidth != strokeWidth;
  }
}
