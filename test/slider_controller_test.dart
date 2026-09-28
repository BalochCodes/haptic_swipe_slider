import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_swipe_slider/haptic_swipe_slider.dart';

void main() {
  group('HapticSwipeSliderController Tests', () {
    test('Initializes with default idle state and zero progress', () {
      final controller = HapticSwipeSliderController();
      expect(controller.state, equals(HapticSliderState.idle));
      expect(controller.progress, equals(0.0));
      expect(controller.isIdle, isTrue);
      expect(controller.isDragging, isFalse);
      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);
      expect(controller.isError, isFalse);
    });

    test('updateProgress clamps values between 0.0 and 1.0 and notifies listeners', () {
      final controller = HapticSwipeSliderController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.updateProgress(0.5);
      expect(controller.progress, equals(0.5));
      expect(notifyCount, equals(1));

      // Clamp above 1.0
      controller.updateProgress(1.4);
      expect(controller.progress, equals(1.0));
      expect(notifyCount, equals(2));

      // Clamp below 0.0
      controller.updateProgress(-0.2);
      expect(controller.progress, equals(0.0));
      expect(notifyCount, equals(3));
    });

    test('updateState transitions states accurately', () {
      final controller = HapticSwipeSliderController();
      final states = <HapticSliderState>[];
      controller.addListener(() => states.add(controller.state));

      controller.setLoading();
      expect(controller.isLoading, isTrue);

      controller.setSuccess();
      expect(controller.isSuccess, isTrue);

      controller.setError();
      expect(controller.isError, isTrue);

      expect(states, equals([
        HapticSliderState.loading,
        HapticSliderState.success,
        HapticSliderState.error,
      ]));
    });

    test('attach and reset invoke registered callbacks', () {
      final controller = HapticSwipeSliderController();
      bool resetCalled = false;
      bool completeCalled = false;

      controller.attach(
        onReset: () => resetCalled = true,
        onComplete: () => completeCalled = true,
      );

      controller.complete();
      expect(completeCalled, isTrue);
      expect(controller.progress, equals(1.0));

      controller.reset();
      expect(resetCalled, isTrue);
      expect(controller.progress, equals(0.0));
      expect(controller.isIdle, isTrue);

      controller.detach();
      resetCalled = false;
      controller.reset();
      expect(resetCalled, isFalse);
    });
  });
}
