import 'package:flutter/services.dart';

/// Preset tactile intensity profiles for [HapticSwipeSlider].
enum HapticFeedbackStrength {
  /// All haptic triggers are silenced.
  none,

  /// Subtle ticks with light impacts and selection clicks.
  subtle,

  /// Balanced tactile sensation suitable for standard checkout or unlock actions.
  standard,

  /// Pronounced tactile sensation with heavy impacts and vibrations on confirm.
  heavy,
}

/// Helper class that orchestrates multi-stage tactile responses during drag interactions.
class HapticFeedbackManager {
  final HapticFeedbackStrength strength;
  final bool enableMilestones;
  final List<double> milestoneIntervals;

  final Set<int> _triggeredMilestones = <int>{};

  HapticFeedbackManager({
    this.strength = HapticFeedbackStrength.standard,
    this.enableMilestones = true,
    this.milestoneIntervals = const [0.25, 0.50, 0.75],
  });

  /// Called when the user initiates a drag gesture on the thumb.
  Future<void> onDragStart() async {
    if (strength == HapticFeedbackStrength.none) return;
    _triggeredMilestones.clear();

    try {
      switch (strength) {
        case HapticFeedbackStrength.subtle:
          await HapticFeedback.selectionClick();
          break;
        case HapticFeedbackStrength.standard:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackStrength.heavy:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackStrength.none:
          break;
      }
    } catch (_) {
      // Safe guard for platforms without haptic engine support.
    }
  }

  /// Evaluates the drag progress (0.0 to 1.0) and fires haptic ticks as milestones are crossed.
  Future<void> onProgress(double progress) async {
    if (strength == HapticFeedbackStrength.none || !enableMilestones) return;

    for (int i = 0; i < milestoneIntervals.length; i++) {
      final milestone = milestoneIntervals[i];
      if (progress >= milestone && !_triggeredMilestones.contains(i)) {
        _triggeredMilestones.add(i);
        try {
          if (strength == HapticFeedbackStrength.heavy) {
            await HapticFeedback.mediumImpact();
          } else {
            await HapticFeedback.selectionClick();
          }
        } catch (_) {}
      } else if (progress < milestone && _triggeredMilestones.contains(i)) {
        // Allow re-triggering if user drags backwards and forwards again
        _triggeredMilestones.remove(i);
      }
    }
  }

  /// Called when the drag threshold is reached and confirmation is locked.
  Future<void> onConfirm() async {
    if (strength == HapticFeedbackStrength.none) return;

    try {
      switch (strength) {
        case HapticFeedbackStrength.subtle:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackStrength.standard:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackStrength.heavy:
          await HapticFeedback.vibrate();
          await Future.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackStrength.none:
          break;
      }
    } catch (_) {}
  }

  /// Called when the user releases before reaching the threshold, causing spring-back.
  Future<void> onCancel() async {
    if (strength == HapticFeedbackStrength.none) return;
    _triggeredMilestones.clear();

    try {
      if (strength == HapticFeedbackStrength.heavy) {
        await HapticFeedback.lightImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (_) {}
  }

  /// Resets internal milestone tracking state.
  void reset() {
    _triggeredMilestones.clear();
  }
}
