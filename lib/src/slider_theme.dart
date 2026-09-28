import 'package:flutter/material.dart';

/// Visual styling and decoration parameters for [HapticSwipeSlider].
class HapticSwipeSliderStyle {
  /// Track background color in idle state.
  final Color trackColor;

  /// Optional gradient for the track background. Takes precedence over [trackColor].
  final Gradient? trackGradient;

  /// Border outline for the track pill container.
  final BoxBorder? trackBorder;

  /// Box shadows applied to the track container.
  final List<BoxShadow>? trackShadow;

  /// Background color of the trail filled behind the dragging thumb.
  final Color activeTrackColor;

  /// Optional gradient for the active trail.
  final Gradient? activeTrackGradient;

  /// Background color of the thumb handle.
  final Color thumbColor;

  /// Optional gradient for the thumb handle. Takes precedence over [thumbColor].
  final Gradient? thumbGradient;

  /// Box shadows applied to the thumb handle.
  final List<BoxShadow>? thumbShadow;

  /// Border outline for the thumb handle.
  final BoxBorder? thumbBorder;

  /// Track background color when state is [HapticSliderState.success].
  final Color? completedTrackColor;

  /// Optional gradient for track when completed.
  final Gradient? completedTrackGradient;

  /// Color used for the success state thumb and checkmark.
  final Color successColor;

  /// Color used for the error state thumb and icon.
  final Color errorColor;

  /// Color used for the loading spinner.
  final Color loadingColor;

  /// Text style for the idle label.
  final TextStyle textStyle;

  /// Text style for the label in completed/success state.
  final TextStyle? completedTextStyle;

  /// Color of the shimmer reflection moving across the text.
  final Color shimmerColor;

  /// Border radius of the slider container and active trail.
  final BorderRadiusGeometry borderRadius;

  const HapticSwipeSliderStyle({
    this.trackColor = const Color(0xFF1E222D),
    this.trackGradient,
    this.trackBorder,
    this.trackShadow,
    this.activeTrackColor = const Color(0xFF3B82F6),
    this.activeTrackGradient,
    this.thumbColor = Colors.white,
    this.thumbGradient,
    this.thumbShadow = const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
    this.thumbBorder,
    this.completedTrackColor = const Color(0xFF10B981),
    this.completedTrackGradient,
    this.successColor = const Color(0xFF10B981),
    this.errorColor = const Color(0xFFEF4444),
    this.loadingColor = const Color(0xFF3B82F6),
    this.textStyle = const TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    this.completedTextStyle,
    this.shimmerColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
  });

  /// Premium sleek dark theme.
  factory HapticSwipeSliderStyle.dark({
    Color activeColor = const Color(0xFF6366F1),
    Color trackColor = const Color(0xFF18181B),
  }) {
    return HapticSwipeSliderStyle(
      trackColor: trackColor,
      trackBorder: Border.all(color: const Color(0xFF27272A), width: 1.2),
      activeTrackColor: activeColor.withAlpha(200),
      activeTrackGradient: LinearGradient(
        colors: [activeColor.withAlpha(120), activeColor],
      ),
      thumbColor: Colors.white,
      thumbShadow: [
        BoxShadow(
          color: activeColor.withAlpha(90),
          blurRadius: 14,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
      textStyle: const TextStyle(
        color: Color(0xFFA1A1AA),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  /// Clean, modern light theme.
  factory HapticSwipeSliderStyle.light({
    Color activeColor = const Color(0xFF2563EB),
    Color trackColor = const Color(0xFFF1F5F9),
  }) {
    return HapticSwipeSliderStyle(
      trackColor: trackColor,
      trackBorder: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      activeTrackColor: activeColor,
      activeTrackGradient: LinearGradient(
        colors: [activeColor.withAlpha(180), activeColor],
      ),
      thumbColor: Colors.white,
      thumbShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
      textStyle: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      shimmerColor: activeColor,
    );
  }

  /// High-impact neon glowing theme.
  factory HapticSwipeSliderStyle.neon({
    Color glowColor = const Color(0xFF06B6D4),
  }) {
    return HapticSwipeSliderStyle(
      trackColor: const Color(0xFF0F172A),
      trackBorder: Border.all(color: glowColor.withAlpha(80), width: 1.5),
      activeTrackColor: glowColor,
      activeTrackGradient: LinearGradient(
        colors: [glowColor.withAlpha(100), glowColor],
      ),
      thumbColor: glowColor,
      thumbShadow: [
        BoxShadow(
          color: glowColor.withAlpha(180),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
      textStyle: TextStyle(
        color: glowColor.withAlpha(200),
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      shimmerColor: Colors.white,
    );
  }

  /// Destructive/danger action theme (e.g., Slide to Delete, Terminate Account).
  factory HapticSwipeSliderStyle.danger({
    Color dangerColor = const Color(0xFFDC2626),
  }) {
    return HapticSwipeSliderStyle(
      trackColor: const Color(0xFF2B1214),
      trackBorder: Border.all(color: dangerColor.withAlpha(90), width: 1.2),
      activeTrackColor: dangerColor,
      activeTrackGradient: LinearGradient(
        colors: [dangerColor.withAlpha(150), dangerColor],
      ),
      thumbColor: dangerColor,
      thumbShadow: [
        BoxShadow(
          color: dangerColor.withAlpha(140),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
      textStyle: const TextStyle(
        color: Color(0xFFFCA5A5),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      shimmerColor: Colors.white,
      successColor: dangerColor,
    );
  }
}
