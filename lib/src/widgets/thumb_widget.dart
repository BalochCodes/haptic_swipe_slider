import 'package:flutter/material.dart';
import '../slider_controller.dart';
import '../slider_theme.dart';

/// The interactive circular/pill thumb handle that slides across the track.
class SliderThumb extends StatelessWidget {
  final double size;
  final HapticSliderState state;
  final HapticSwipeSliderStyle style;
  final Widget? icon;
  final Widget? loadingWidget;
  final Widget? successWidget;
  final Widget? errorWidget;

  const SliderThumb({
    super.key,
    required this.size,
    required this.state,
    required this.style,
    this.icon,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveBackground = style.thumbColor;
    Gradient? effectiveGradient = style.thumbGradient;

    if (state == HapticSliderState.success) {
      effectiveBackground = style.successColor;
      effectiveGradient = null;
    } else if (state == HapticSliderState.error) {
      effectiveBackground = style.errorColor;
      effectiveGradient = null;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveGradient == null ? effectiveBackground : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(size / 2),
        border: style.thumbBorder,
        boxShadow: style.thumbShadow,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _buildThumbContent(context),
        ),
      ),
    );
  }

  Widget _buildThumbContent(BuildContext context) {
    switch (state) {
      case HapticSliderState.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: loadingWidget ??
              SizedBox(
                width: size * 0.44,
                height: size * 0.44,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    style.loadingColor,
                  ),
                ),
              ),
        );

      case HapticSliderState.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: successWidget ??
              Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
        );

      case HapticSliderState.error:
        return KeyedSubtree(
          key: const ValueKey('error'),
          child: errorWidget ??
              Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
        );

      case HapticSliderState.idle:
      case HapticSliderState.dragging:
        return KeyedSubtree(
          key: const ValueKey('icon'),
          child: icon ??
              Icon(
                Icons.arrow_forward_rounded,
                color: style.activeTrackColor,
                size: size * 0.52,
              ),
        );
    }
  }
}
