import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SinglePageScrollPhysics extends ScrollPhysics {
  const SinglePageScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  SinglePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SinglePageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      // Overscroll on the top side (left side in horizontal)
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      // Overscroll on the bottom side (right side in horizontal)
      return value - position.pixels;
    }
    return 0.0;
  }

  @override
  double get minFlingVelocity => kIsWeb ? 8000.0 : 150.0; // Adjusted for web

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (position.viewportDimension == 0.0) {
      // Avoid dividing by zero by returning a non-infinite simulation
      return null;
    }

    double targetPage =
        (position.pixels / position.viewportDimension).roundToDouble();

    // Clamp the targetPage to ensure it's within valid bounds
    targetPage = targetPage.clamp(
        0.0,
        (position.maxScrollExtent / position.viewportDimension)
            .floorToDouble());

    final double targetPixels = targetPage * position.viewportDimension;

    // Web-specific adjustment: clamp velocity and ensure proper snapping
    if (kIsWeb && velocity.abs() > 8000) {
      velocity = 8000 * velocity.sign;
    }

    // Check if we are overscrolling (elastic effect needed)
    if (position.pixels < position.minScrollExtent ||
        position.pixels > position.maxScrollExtent) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }

    // Normal page snapping behavior
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => true;
}
