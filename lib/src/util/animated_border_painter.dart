import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Creates an animated border that wraps the tray image.
class AnimatedBorderPainter extends CustomPainter {
  AnimatedBorderPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradientColors,
    required this.gapSize,
    required this.animation,
    this.numberOfStories = 2,
    this.spaceLength = 10,
    this.colorStops,
  }) : super(repaint: animation);

  final double gapSize;
  final double radius;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Animation<double> animation;
  final List<double>? colorStops;
  //number of stories
  final int numberOfStories;
  //length of the space arc (empty one)
  final int spaceLength;
  //start of the arc painting in degree(0-360)
  double startOfArcInDegree = 0;

  final _painter = Paint();
  late final Rect _outerRect;
  Path? path;

//drawArc deals with rads, easier for me to use degrees
  //so this takes a degree and change it to rad
  double inRads(double degree) {
    return (degree * math.pi) / 180;
  }

  /// Creates path for tray border. This path is not changes when tray
  /// animating.
  Path _createPath(Size size) {
    // Create outer rectangle equals size
    _outerRect = Offset.zero & size;
    final outerRRect =
        RRect.fromRectAndRadius(_outerRect, Radius.circular(radius));

    // Create inner rectangle smaller by strokeWidth
    final Rect innerRect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );

    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(
        radius - strokeWidth,
      ),
    );

    // Create difference between outer and inner paths and draw it
    final Path path1 = Path()..addRRect(outerRRect);
    final Path path2 = Path()..addRRect(innerRRect);

    return Path.combine(PathOperation.difference, path1, path2);
  }

  /// Updates shader using current animation value.
  Paint _updateShader() {
    // Rotate gradient to create gradient effect.
    final gradient = SweepGradient(
      colors: gradientColors,
      stops: colorStops,
      transform: GradientRotation(animation.value * 2 * math.pi),
    );

    // Apply gradient shader
    _painter.shader = gradient.createShader(_outerRect);

    return _painter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // path ??= _createPath(size);
    // _updateShader();

    //circle angle is 360, remove all space arcs between the main story arc (the number of spaces(stories) times the  space length
    //then subtract the number from 360 to get ALL arcs length
    //then divide the ALL arcs length by number of Arc (number of stories) to get the exact length of one arc
    double arcLength =
        (360 - (numberOfStories * spaceLength)) / numberOfStories;

    //be careful here when arc is a negative number
    //that happens when the number of spaces is more than 360
    //feel free to use what logic you want to take care of that
    //note that numberOfStories should be limited too here
    if (arcLength <= 0) {
      arcLength = 360 / spaceLength - 1;
    }

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    //looping for number of stories to draw every story arc
    for (int i = 0; i < numberOfStories; i++) {
      //printing the arc
      canvas.drawArc(
          rect,
          inRads(startOfArcInDegree),
          //be careful here is:  "double sweepAngle", not "end"
          inRads(arcLength),
          false,
          Paint()
            //here you can compare your SEEN story index with the arc index to make it grey
            ..color = Colors.teal
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke);

      //the logic of spaces between the arcs is to start the next arc after jumping the length of space
      startOfArcInDegree += arcLength + spaceLength;

      // canvas.drawPath(path!, _painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
