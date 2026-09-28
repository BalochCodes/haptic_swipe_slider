import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_swipe_slider/haptic_swipe_slider.dart';

void main() {
  group('HapticSwipeSlider Widget Tests', () {
    testWidgets('Renders prompt label and slider thumb with default styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  text: 'Slide to Confirm',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Slide to Confirm'), findsOneWidget);
      expect(find.byType(SliderThumb), findsOneWidget);
    });

    testWidgets('Full swipe past threshold triggers onConfirm callback',
        (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  text: 'Slide to Unlock',
                  completedText: 'Unlocked!',
                  threshold: 0.8,
                  onConfirm: () {
                    confirmed = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final thumbFinder = find.byType(SliderThumb);
      expect(thumbFinder, findsOneWidget);

      // Perform swipe gesture
      await tester.drag(thumbFinder, const Offset(250, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text('Unlocked!'), findsOneWidget);
    });

    testWidgets('Partial drag below threshold springs back and triggers onCancel',
        (WidgetTester tester) async {
      bool canceled = false;
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  text: 'Slide to Pay',
                  threshold: 0.85,
                  onConfirm: () => confirmed = true,
                  onCancel: () => canceled = true,
                ),
              ),
            ),
          ),
        ),
      );

      final thumbFinder = find.byType(SliderThumb);

      // Small drag that does not reach 85% threshold
      await tester.drag(thumbFinder, const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 400));

      expect(confirmed, isFalse);
      expect(canceled, isTrue);
      expect(find.text('Slide to Pay'), findsOneWidget);
    });

    testWidgets('Async onConfirm displays loading state then transitions to success',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  text: 'Slide to Verify',
                  loadingText: 'Verifying...',
                  completedText: 'Verified!',
                  threshold: 0.7,
                  onConfirm: () async {
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final thumbFinder = find.byType(SliderThumb);

      // Drag to confirm
      await tester.drag(thumbFinder, const Offset(260, 0));
      await tester.pump(); // Start confirmation animation
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Verifying...'), findsOneWidget);

      // Await async completion
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Verified!'), findsOneWidget);
    });

    testWidgets('Programmatic controller reset restores slider to idle position',
        (WidgetTester tester) async {
      final controller = HapticSwipeSliderController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  controller: controller,
                  text: 'Slide to Authorize',
                  completedText: 'Authorized',
                ),
              ),
            ),
          ),
        ),
      );

      final thumbFinder = find.byType(SliderThumb);

      // Complete via drag
      await tester.drag(thumbFinder, const Offset(260, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(controller.isSuccess, isTrue);

      // Programmatically reset
      controller.reset();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(controller.isIdle, isTrue);
      expect(controller.progress, equals(0.0));
      expect(find.text('Slide to Authorize'), findsOneWidget);
    });

    testWidgets('Renders with reversed (right-to-left) direction',
        (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: HapticSwipeSlider(
                  text: 'Slide Left to Delete',
                  reversed: true,
                  threshold: 0.7,
                  onConfirm: () => confirmed = true,
                ),
              ),
            ),
          ),
        ),
      );

      final thumbFinder = find.byType(SliderThumb);

      // Drag to the left
      await tester.drag(thumbFinder, const Offset(-250, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
