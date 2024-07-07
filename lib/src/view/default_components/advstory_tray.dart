import 'dart:math';

import 'package:advstory/advstory.dart';
import 'package:advstory/src/view/components/shimmer.dart';
import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:dotted_box/dotted_box.dart';
import 'package:flutter/material.dart';

/// A highly customizable animated story tray.
///
/// Circular or rectangular image with gradient border. Shows shimmer effect
/// when tray image is getting ready to show.
///
/// When tapped, this widget starts a border rotation animation and stops the
/// animation when [AdvStory] prepares the contents of the tray.
///
/// [AdvStoryTray] is a predefined component, any widget can be used as a
/// story tray but it's recommended to create an animated tray by extending
/// [AnimatedTray] class.
///
/// ---
/// AdvStory checks the tray widget type when the tray builder is called. If
/// tray is subtype of [AnimatedTray], [AdvStory] prepares the tray content
/// before displaying the story view and manages the starting and stopping of
/// the tray animation.
///
/// See [AnimatedTray] for more information.
class AdvStoryTray extends AnimatedTray {
  /// Creates a story tray to show in story tray list.
  ///
  /// [borderRadius] sets tray and image border shape.
  AdvStoryTray({
    Key? key,
    required this.url,
    this.base64Url,
    this.username,
    this.numberOfStories,
    this.spaceLength,
    this.color,
    this.size = const Size(80, 80),
    this.shimmerStyle = const ShimmerStyle(),
    this.shape = BoxShape.circle,
    this.borderGradientColors = const [
      Color(0xaf405de6),
      Color(0xaf5851db),
      Color(0xaf833ab4),
      Color(0xafc13584),
      Color(0xafe1306c),
      Color(0xaffd1d1d),
      Color(0xaf405de6),
    ],
    this.gapSize = 3,
    this.strokeWidth = 2,
    this.animationDuration = const Duration(milliseconds: 1200),
    double? borderRadius,
  })  : assert(
          (() => shape == BoxShape.circle ? size.width == size.height : true)(),
          'Size width and height must be equal for a circular tray',
        ),
        assert(
          borderGradientColors.length >= 2,
          'At least 2 colors are required for tray border gradient',
        ),
        borderRadius = shape == BoxShape.circle
            ? size.width
            : borderRadius ?? size.width / 10,
        super(key: key);

  /// Image url that shown as tray.
  final String url;

  /// base64Url.
  final String? base64Url;

  /// Name of the user who posted the story. This username is displayed
  /// below the story tray.
  final Widget? username;

  /// Size of the story tray. For a circular tray, width and height must be
  /// equal.
  final Size size;

  /// Border gradient colors. Two same color creates a solid border.
  final List<Color> borderGradientColors;

  /// Style of the shimmer that showing while preparing the tray content.
  final ShimmerStyle shimmerStyle;

  /// Shap of the tray.
  final BoxShape shape;

  /// Width of the stroke that wraps the tray image.
  final double strokeWidth;

  /// Radius of the border that wraps the tray image.
  final double borderRadius;

  /// Transparent area size between image and the border.
  final double gapSize;

  /// Rotate animation duration of the border.
  final Duration animationDuration;

  /// color of dash
  final Color? color;

  ///number of stories
  final int? numberOfStories;

  ///length of the space arc (empty one)
  final int? spaceLength;
  @override
  AnimatedTrayState<AdvStoryTray> createState() => _AdvStoryTrayState();
}

/// State of the [AdvStoryTray] widget.
class _AdvStoryTrayState extends AnimatedTrayState<AdvStoryTray>
    with TickerProviderStateMixin {
  late final _rotationController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );
  late List<Color> _gradientColors = widget.borderGradientColors;
  List<Color> _fadedColors = [];

  List<Color> _calculateFadedColors(List<Color> baseColors) {
    final colors = <Color>[];
    for (int i = 0; i < baseColors.length; i++) {
      final opacity = i == 0 ? 1 / baseColors.length : 1 / i;

      colors.add(
        baseColors[i].withOpacity(opacity),
      );
    }

    return colors;
  }

  @override
  void startAnimation() {
    setState(() {
      _gradientColors = _fadedColors;
    });

    _rotationController.repeat();
  }

  @override
  void stopAnimation() {
    _rotationController.reset();

    setState(() {
      _gradientColors = widget.borderGradientColors;
    });
  }

  @override
  void initState() {
    _fadedColors = _calculateFadedColors(widget.borderGradientColors);

    super.initState();
  }

  @override
  void didUpdateWidget(AdvStoryTray oldWidget) {
    if (oldWidget.borderGradientColors != widget.borderGradientColors) {
      _gradientColors = widget.borderGradientColors;
      _fadedColors = _calculateFadedColors(widget.borderGradientColors);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: widget.numberOfStories == 1
                    ? Container(
                        width: widget.size.width,
                        height: widget.size.height,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: widget.color ?? Colors.green,
                              width: widget.strokeWidth),
                        ),
                        child: _childContent,
                      )
                    : DottedBox(
                        width: widget.size.width,
                        height: widget.size.height,
                        borderThickness: widget.strokeWidth,
                        borderColor: widget.color,
                        borderRadius: 20,
                        space: widget.spaceLength ?? 10,
                        borderShape: Shape.circle,
                        dashCounts: widget.numberOfStories ?? 1,
                        child: _childContent),
              ),
            ],
          ),
        ),
        if (widget.username != null) ...[
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.username,
          ),
        ],
      ],
    );
  }

  Widget get _childContent => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.borderRadius - (widget.strokeWidth + widget.gapSize),
          ),
          child: widget.base64Url != null
              ? CachedMemoryImage(
                  width: widget.size.width -
                      (widget.gapSize + widget.strokeWidth) * 2,
                  height: widget.size.height -
                      (widget.gapSize + widget.strokeWidth) * 2,
                  fit: BoxFit.cover,
                  uniqueKey: 'app/image/${widget.base64Url?.substring(0, 50)}',
                  base64: widget.base64Url,
                  frameBuilder: (context, child, frame, _) {
                    return frame != null
                        ? TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: .1, end: 1),
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 300),
                            builder: (BuildContext context, double opacity, _) {
                              return Opacity(
                                opacity: opacity,
                                child: child,
                              );
                            },
                          )
                        : Shimmer(style: widget.shimmerStyle);
                  },
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.error);
                  },
                )
              : Image.network(
                  widget.url,
                  width: widget.size.width -
                      (widget.gapSize + widget.strokeWidth) * 2,
                  height: widget.size.height -
                      (widget.gapSize + widget.strokeWidth) * 2,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, _) {
                    return frame != null
                        ? TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: .1, end: 1),
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 300),
                            builder: (BuildContext context, double opacity, _) {
                              return Opacity(
                                opacity: opacity,
                                child: child,
                              );
                            },
                          )
                        : Shimmer(style: widget.shimmerStyle);
                  },
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.error);
                  },
                ),
        ),
      );
}

class DottedBorder extends CustomPainter {
  //number of stories
  final int numberOfStories;
  //length of the space arc (empty one)
  final int spaceLength;
  final double? strokeWidth;
  final Color? color;
  //start of the arc painting in degree(0-360)
  double startOfArcInDegree = 0;

  DottedBorder(
      {required this.numberOfStories,
      this.spaceLength = 10,
      this.strokeWidth = 5.0,
      this.color = Colors.teal});

  //drawArc deals with rads, easier for me to use degrees
  //so this takes a degree and change it to rad
  double inRads(double degree) {
    return (degree * pi) / 180;
  }

  @override
  bool shouldRepaint(DottedBorder oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
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
      print('object:${startOfArcInDegree}');
      print('object:${arcLength}');
      //printing the arc
      canvas.drawArc(
          rect,
          inRads(startOfArcInDegree),
          //be careful here is:  "double sweepAngle", not "end"
          inRads(arcLength),
          false,
          Paint()
            //here you can compare your SEEN story index with the arc index to make it grey
            ..color = color!
            ..strokeWidth = strokeWidth!
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.fill);

      //the logic of spaces between the arcs is to start the next arc after jumping the length of space
      startOfArcInDegree += arcLength + spaceLength;
    }
  }
}
