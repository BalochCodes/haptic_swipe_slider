import 'package:flutter/foundation.dart';

/// Represents the lifecycle state of a [HapticSwipeSlider].
enum HapticSliderState {
  /// The slider is stationary at the starting position awaiting user interaction.
  idle,

  /// The user is actively dragging the thumb across the track.
  dragging,

  /// Asynchronous action is in progress after reaching confirmation threshold.
  loading,

  /// Confirmation action succeeded.
  success,

  /// Confirmation action failed or was rejected.
  error,
}

/// Controller allowing programmatic inspection and manipulation of [HapticSwipeSlider].
class HapticSwipeSliderController extends ChangeNotifier {
  HapticSliderState _state = HapticSliderState.idle;
  double _progress = 0.0;

  /// Function registered by the widget state to trigger a smooth reset.
  VoidCallback? _onResetRequested;

  /// Function registered by the widget state to trigger a smooth completion.
  VoidCallback? _onCompleteRequested;

  /// The current lifecycle state of the slider.
  HapticSliderState get state => _state;

  /// The current drag progress from `0.0` (idle) to `1.0` (fully swiped).
  double get progress => _progress;

  /// Whether the slider is currently idle.
  bool get isIdle => _state == HapticSliderState.idle;

  /// Whether the thumb is currently being dragged.
  bool get isDragging => _state == HapticSliderState.dragging;

  /// Whether the slider is in the loading state.
  bool get isLoading => _state == HapticSliderState.loading;

  /// Whether the action has succeeded.
  bool get isSuccess => _state == HapticSliderState.success;

  /// Whether the slider is in an error state.
  bool get isError => _state == HapticSliderState.error;

  /// Internal setter for progress used by the slider widget.
  void updateProgress(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if ((_progress - clamped).abs() > 0.0001) {
      _progress = clamped;
      notifyListeners();
    }
  }

  /// Internal setter for state used by the slider widget.
  void updateState(HapticSliderState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Programmatically triggers a reset animation to bring the thumb back to 0.0.
  void reset() {
    _state = HapticSliderState.idle;
    _progress = 0.0;
    notifyListeners();
    _onResetRequested?.call();
  }

  /// Programmatically triggers completion and slides thumb to 1.0.
  void complete() {
    _progress = 1.0;
    notifyListeners();
    _onCompleteRequested?.call();
  }

  /// Transitions the slider state to [HapticSliderState.loading].
  void setLoading() {
    updateState(HapticSliderState.loading);
  }

  /// Transitions the slider state to [HapticSliderState.success].
  void setSuccess() {
    updateState(HapticSliderState.success);
  }

  /// Transitions the slider state to [HapticSliderState.error].
  void setError() {
    updateState(HapticSliderState.error);
  }

  /// Binds internal widget callbacks for reset and completion animations.
  void attach({
    required VoidCallback onReset,
    required VoidCallback onComplete,
  }) {
    _onResetRequested = onReset;
    _onCompleteRequested = onComplete;
  }

  /// Detaches internal widget callbacks upon disposal.
  void detach() {
    _onResetRequested = null;
    _onCompleteRequested = null;
  }
}
