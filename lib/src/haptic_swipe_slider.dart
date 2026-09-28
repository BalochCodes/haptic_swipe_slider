import 'dart:async';
import 'package:flutter/material.dart';
import 'haptic_feedback_manager.dart';
import 'slider_controller.dart';
import 'slider_theme.dart';
import 'widgets/shimmer_sweep.dart';
import 'widgets/thumb_widget.dart';

/// A modern, liquid-smooth slide-to-confirm pill slider with tactile haptic feedback,
/// magnetic spring-back physics, dynamic trail filling, and async lifecycle states.
class HapticSwipeSlider extends StatefulWidget {
  /// The prompt text displayed inside the slider track when idle.
  final String text;

  /// Optional text displayed when the confirmation action succeeds.
  final String? completedText;

  /// Optional text displayed while an asynchronous [onConfirm] action is in progress.
  final String? loadingText;

  /// Primary callback triggered when the user slides past the confirmation threshold.
  /// If this returns a [Future], the slider automatically transitions to the
  /// loading state and waits for completion.
  final FutureOr<void> Function()? onConfirm;

  /// Optional callback invoked if the user releases the slider before the threshold.
  final VoidCallback? onCancel;

  /// Optional callback invoked whenever the drag progress updates (range 0.0 to 1.0).
  final ValueChanged<double>? onProgressChanged;

  /// Optional callback invoked when the slider lifecycle state changes.
  final ValueChanged<HapticSliderState>? onStateChanged;

  /// Programmatic controller to reset, complete, or update slider states.
  final HapticSwipeSliderController? controller;

  /// Visual theme and styling configuration.
  final HapticSwipeSliderStyle style;

  /// Tactile feedback intensity profile.
  final HapticFeedbackStrength hapticStrength;

  /// Whether milestone tactile clicks are triggered as the thumb crosses specific progress points.
  final bool enableMilestoneHaptics;

  /// Milestone points (from 0.0 to 1.0) where tactile clicks will fire.
  final List<double> milestoneIntervals;

  /// The fraction of track distance required to lock confirmation (defaults to `0.82`).
  final double threshold;

  /// Overall slider width. Defaults to full available width.
  final double? width;

  /// Overall slider track height. Defaults to `56.0`.
  final double height;

  /// Padding between track boundaries and the thumb button. Defaults to `EdgeInsets.all(4.0)`.
  final EdgeInsets padding;

  /// Custom icon widget inside the thumb.
  final Widget? thumbIcon;

  /// Custom widget shown inside thumb during loading state.
  final Widget? loadingWidget;

  /// Custom widget shown inside thumb on success.
  final Widget? successWidget;

  /// Custom widget shown inside thumb on error.
  final Widget? errorWidget;

  /// Whether the animated shimmer sweep effect across the prompt text is active.
  final bool enableShimmer;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Duration to wait after a successful confirmation before automatically resetting.
  /// If `null`, the slider stays locked in completed state until programmatically reset.
  final Duration? autoResetDuration;

  /// Duration of the spring-back animation when released early. Defaults to 320ms.
  final Duration springDuration;

  /// Curve of the spring-back animation. Defaults to [Curves.easeOutBack].
  final Curve springCurve;

  /// Whether the slide direction is right-to-left. Defaults to `false` (left-to-right).
  final bool reversed;

  const HapticSwipeSlider({
    super.key,
    this.text = 'Slide to Confirm',
    this.completedText,
    this.loadingText,
    this.onConfirm,
    this.onCancel,
    this.onProgressChanged,
    this.onStateChanged,
    this.controller,
    this.style = const HapticSwipeSliderStyle(),
    this.hapticStrength = HapticFeedbackStrength.standard,
    this.enableMilestoneHaptics = true,
    this.milestoneIntervals = const [0.25, 0.50, 0.75],
    this.threshold = 0.82,
    this.width,
    this.height = 56.0,
    this.padding = const EdgeInsets.all(4.0),
    this.thumbIcon,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.enableShimmer = true,
    this.enabled = true,
    this.autoResetDuration,
    this.springDuration = const Duration(milliseconds: 320),
    this.springCurve = Curves.easeOutBack,
    this.reversed = false,
  }) : assert(threshold > 0.0 && threshold <= 1.0, 'Threshold must be between 0.0 and 1.0');

  @override
  State<HapticSwipeSlider> createState() => _HapticSwipeSliderState();
}

class _HapticSwipeSliderState extends State<HapticSwipeSlider>
    with SingleTickerProviderStateMixin {
  late final HapticFeedbackManager _hapticManager;
  late final AnimationController _animController;
  Animation<double>? _dragAnimation;

  double _dragOffset = 0.0;
  double _maxDragDistance = 0.0;
  HapticSliderState _state = HapticSliderState.idle;
  Timer? _autoResetTimer;

  HapticSwipeSliderController? _internalController;
  HapticSwipeSliderController get _effectiveController =>
      widget.controller ?? (_internalController ??= HapticSwipeSliderController());

  @override
  void initState() {
    super.initState();
    _hapticManager = HapticFeedbackManager(
      strength: widget.hapticStrength,
      enableMilestones: widget.enableMilestoneHaptics,
      milestoneIntervals: widget.milestoneIntervals,
    );

    _animController = AnimationController(
      vsync: this,
      duration: widget.springDuration,
    );

    _effectiveController.attach(
      onReset: _handleProgrammaticReset,
      onComplete: _handleProgrammaticComplete,
    );
  }

  @override
  void didUpdateWidget(covariant HapticSwipeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach();
      _effectiveController.attach(
        onReset: _handleProgrammaticReset,
        onComplete: _handleProgrammaticComplete,
      );
    }
  }

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    _animController.dispose();
    widget.controller?.detach();
    _internalController?.dispose();
    super.dispose();
  }

  void _setState(HapticSliderState newState) {
    if (_state != newState) {
      setState(() => _state = newState);
      _effectiveController.updateState(newState);
      widget.onStateChanged?.call(newState);
    }
  }

  void _updateProgress(double offset) {
    final progress = _maxDragDistance > 0 ? (offset / _maxDragDistance).clamp(0.0, 1.0) : 0.0;
    _effectiveController.updateProgress(progress);
    widget.onProgressChanged?.call(progress);
    _hapticManager.onProgress(progress);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled || _state == HapticSliderState.loading || _state == HapticSliderState.success) {
      return;
    }
    _autoResetTimer?.cancel();
    _animController.stop();
    _setState(HapticSliderState.dragging);
    _hapticManager.onDragStart();
  }

  void _onHorizontalDragUpdate(DragStartDetails details, DragUpdateDetails updateDetails) {
    if (!widget.enabled || _state != HapticSliderState.dragging || _maxDragDistance <= 0) {
      return;
    }

    final delta = widget.reversed ? -updateDetails.primaryDelta! : updateDetails.primaryDelta!;
    final newOffset = (_dragOffset + delta).clamp(0.0, _maxDragDistance);

    setState(() {
      _dragOffset = newOffset;
    });

    _updateProgress(_dragOffset);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enabled || _state != HapticSliderState.dragging || _maxDragDistance <= 0) {
      return;
    }

    final currentProgress = _dragOffset / _maxDragDistance;
    final velocity = widget.reversed ? -details.primaryVelocity! : details.primaryVelocity!;

    // Trigger confirmation if passed threshold or fast fling towards the end
    if (currentProgress >= widget.threshold || (velocity > 600 && currentProgress > 0.45)) {
      _confirmAndSnapToEnd();
    } else {
      _cancelAndSpringBack();
    }
  }

  void _confirmAndSnapToEnd() async {
    _hapticManager.onConfirm();

    _animController.duration = const Duration(milliseconds: 140);
    _dragAnimation = Tween<double>(
      begin: _dragOffset,
      end: _maxDragDistance,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.addListener(_onAnimTick);
    await _animController.forward(from: 0.0);
    _animController.removeListener(_onAnimTick);

    _dragOffset = _maxDragDistance;
    _updateProgress(_dragOffset);

    if (widget.onConfirm != null) {
      _setState(HapticSliderState.loading);
      try {
        final result = widget.onConfirm!();
        if (result is Future) {
          await result;
        }
        if (!mounted) return;
        _setState(HapticSliderState.success);
      } catch (_) {
        if (!mounted) return;
        _setState(HapticSliderState.error);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) _cancelAndSpringBack();
        return;
      }
    } else {
      _setState(HapticSliderState.success);
    }

    if (widget.autoResetDuration != null && mounted) {
      _autoResetTimer?.cancel();
      _autoResetTimer = Timer(widget.autoResetDuration!, () {
        if (mounted) {
          _handleProgrammaticReset();
        }
      });
    }
  }

  void _cancelAndSpringBack() {
    _hapticManager.onCancel();
    widget.onCancel?.call();

    _animController.duration = widget.springDuration;
    _dragAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: widget.springCurve));

    _animController.addListener(_onAnimTick);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        _animController.removeListener(_onAnimTick);
        setState(() {
          _dragOffset = 0.0;
        });
        _updateProgress(0.0);
        _setState(HapticSliderState.idle);
        _hapticManager.reset();
      }
    });
  }

  void _onAnimTick() {
    if (_dragAnimation != null && mounted) {
      setState(() {
        _dragOffset = _dragAnimation!.value;
      });
      _updateProgress(_dragOffset);
    }
  }

  void _handleProgrammaticReset() {
    _autoResetTimer?.cancel();
    _animController.duration = widget.springDuration;
    _dragAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: widget.springCurve));

    _animController.addListener(_onAnimTick);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        _animController.removeListener(_onAnimTick);
        setState(() {
          _dragOffset = 0.0;
        });
        _updateProgress(0.0);
        _setState(HapticSliderState.idle);
        _hapticManager.reset();
      }
    });
  }

  void _handleProgrammaticComplete() {
    _autoResetTimer?.cancel();
    _animController.duration = const Duration(milliseconds: 200);
    _dragAnimation = Tween<double>(
      begin: _dragOffset,
      end: _maxDragDistance,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.addListener(_onAnimTick);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        _animController.removeListener(_onAnimTick);
        setState(() {
          _dragOffset = _maxDragDistance;
        });
        _updateProgress(_maxDragDistance);
        _setState(HapticSliderState.success);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = widget.width ?? constraints.maxWidth;
        final double thumbSize = widget.height - (widget.padding.vertical);
        _maxDragDistance = (effectiveWidth - thumbSize - widget.padding.horizontal).clamp(0.0, double.infinity);

        final double currentProgress = _maxDragDistance > 0 ? (_dragOffset / _maxDragDistance).clamp(0.0, 1.0) : 0.0;

        Color trackBgColor = widget.style.trackColor;
        Gradient? trackBgGradient = widget.style.trackGradient;

        if (_state == HapticSliderState.success && widget.style.completedTrackColor != null) {
          trackBgColor = widget.style.completedTrackColor!;
          trackBgGradient = widget.style.completedTrackGradient;
        }

        return Semantics(
          label: widget.text,
          slider: true,
          value: '${(currentProgress * 100).round()}%',
          child: Container(
            width: effectiveWidth,
            height: widget.height,
            decoration: BoxDecoration(
              color: trackBgGradient == null ? trackBgColor : null,
              gradient: trackBgGradient,
              borderRadius: widget.style.borderRadius,
              border: widget.style.trackBorder,
              boxShadow: widget.style.trackShadow,
            ),
            child: ClipRRect(
              borderRadius: widget.style.borderRadius,
              child: Stack(
                children: [
                  // 1. Active trail expanding behind the dragging thumb
                  _buildActiveTrail(thumbSize, currentProgress),

                  // 2. Central prompt / state label
                  Positioned.fill(
                    child: Center(
                      child: _buildLabel(currentProgress),
                    ),
                  ),

                  // 3. Sliding Thumb Handle
                  _buildSlidingThumb(thumbSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTrail(double thumbSize, double currentProgress) {
    if (currentProgress <= 0.001) return const SizedBox.shrink();

    final trailWidth = _dragOffset + thumbSize + (widget.padding.horizontal);

    return Positioned(
      left: widget.reversed ? null : 0,
      right: widget.reversed ? 0 : null,
      top: 0,
      bottom: 0,
      width: trailWidth,
      child: Container(
        decoration: BoxDecoration(
          color: widget.style.activeTrackGradient == null ? widget.style.activeTrackColor : null,
          gradient: widget.style.activeTrackGradient,
        ),
      ),
    );
  }

  Widget _buildLabel(double currentProgress) {
    String labelText;
    TextStyle style;

    if (_state == HapticSliderState.loading) {
      labelText = widget.loadingText ?? 'Processing...';
      style = widget.style.textStyle;
    } else if (_state == HapticSliderState.success) {
      labelText = widget.completedText ?? 'Confirmed';
      style = widget.style.completedTextStyle ??
          widget.style.textStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          );
    } else {
      labelText = widget.text;
      style = widget.style.textStyle;
    }

    // Smoothly fade out text as thumb slides past it in idle/dragging states
    final double textOpacity = (_state == HapticSliderState.idle || _state == HapticSliderState.dragging)
        ? (1.0 - (currentProgress * 1.5)).clamp(0.0, 1.0)
        : 1.0;

    final textWidget = Opacity(
      opacity: textOpacity,
      child: Text(
        labelText,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (widget.enableShimmer && _state == HapticSliderState.idle) {
      return ShimmerSweep(
        baseColor: style.color ?? Colors.white70,
        highlightColor: widget.style.shimmerColor,
        child: textWidget,
      );
    }

    return textWidget;
  }

  Widget _buildSlidingThumb(double thumbSize) {
    final double thumbPos = widget.padding.left + _dragOffset;

    return Positioned(
      left: widget.reversed ? null : thumbPos,
      right: widget.reversed ? thumbPos : null,
      top: widget.padding.top,
      bottom: widget.padding.bottom,
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(
          DragStartDetails(),
          details,
        ),
        onHorizontalDragEnd: _onHorizontalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: SliderThumb(
          size: thumbSize,
          state: _state,
          style: widget.style,
          icon: widget.thumbIcon,
          loadingWidget: widget.loadingWidget,
          successWidget: widget.successWidget,
          errorWidget: widget.errorWidget,
        ),
      ),
    );
  }
}
