import 'package:flutter/material.dart';

/// A container that adapts its width to the screen size.
class AdaptiveContainer extends StatelessWidget {
  /// The child of this container.
  final Widget child;

  /// Creates a new [AdaptiveContainer].
  const AdaptiveContainer({
    super.key,
    required this.child,
  });

  double _getContainerWidth(double width) {
    if (width >= 1400) return 1320;
    if (width >= 1200) return 1140;
    if (width >= 992) return 960;
    if (width >= 768) return 720;
    if (width >= 576) return 540;
    return width - 20;
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var deviceWidth = queryData.size.width;
    var containerWidth = _getContainerWidth(deviceWidth);

    return Container(
      width: containerWidth,
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: child,
    );
  }
}
