# haptic_swipe_slider 📱

A modern, liquid-smooth slide-to-confirm pill slider with tactile haptic feedback, magnetic spring-back physics, dynamic trail filling, and async lifecycle states.

[![pub package](https://img.shields.io/pub/v/haptic_swipe_slider.svg)](https://pub.dev/packages/haptic_swipe_slider)
[![pub points](https://img.shields.io/pub/points/haptic_swipe_slider?color=2E8B57&label=pub%20points)](https://pub.dev/packages/haptic_swipe_slider/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/BalochCodes/haptic_swipe_slider?style=social)](https://github.com/BalochCodes/haptic_swipe_slider)

Replace generic buttons with an engaging, tactile swipe interaction designed for mission-critical confirmations like fintech payments, smart lock operations, order submissions, and destructive deletions.

---

## ✨ Features

- 🌊 **Liquid Slide-to-Confirm:** Ergonomic pill container with a sliding thumb handle and dynamic color/gradient track fill.
- 🧲 **Magnetic Spring-Back Physics:** Automatically snaps to end when dragged past threshold, or springs back gracefully with authentic bounce curves when released early.
- 📳 **Multi-Stage Tactile Haptics:** Native feedback on drag start, incremental milestone ticks (25%, 50%, 75%), heavy confirmation lock, and cancel clicks.
- 💡 **Shimmer Light Reflection:** Built-in animated sweep reflections guide the user's eye across the prompt text without extra dependencies.
- ⏳ **Integrated Async State Machine:** Seamlessly transitions from `idle` ➔ `dragging` ➔ `loading` (spinner) ➔ `success` (checkmark) or `error`.
- 🎮 **Programmatic Controller:** Full lifecycle inspection and remote triggers via `HapticSwipeSliderController`.
- 🎨 **Prebuilt Factory Themes:** Instant dark, light, cyber neon, and danger themes with deep customization options.
- 🔄 **Reversible Direction:** Support for both left-to-right and right-to-left swipe gestures.

---

## 📦 Installation

Add `haptic_swipe_slider` to your Flutter project:

```bash
flutter pub add haptic_swipe_slider
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  haptic_swipe_slider: ^0.0.1
```

---

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:haptic_swipe_slider/haptic_swipe_slider.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: HapticSwipeSlider(
            text: 'Slide to Pay \$249.00',
            completedText: 'Payment Confirmed! 💳',
            onConfirm: () async {
              // Perform async transaction
              await Future.delayed(const Duration(seconds: 2));
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 💡 Advanced Examples

### 1. Cyber Neon Theme with Auto-Reset

```dart
HapticSwipeSlider(
  text: 'Slide to Unlock Front Door',
  completedText: 'Door Unlocked 🔓',
  loadingText: 'Disarming Alarm...',
  style: HapticSwipeSliderStyle.neon(
    glowColor: const Color(0xFF06B6D4),
  ),
  thumbIcon: const Icon(
    Icons.lock_open_rounded,
    color: Color(0xFF0F172A),
  ),
  autoResetDuration: const Duration(seconds: 3),
  onConfirm: () async {
    await Future.delayed(const Duration(milliseconds: 1200));
  },
)
```

### 2. Critical Destructive Confirmation (Slide to Delete)

```dart
HapticSwipeSlider(
  text: 'Slide to Delete Project',
  completedText: 'Project Deleted 🗑️',
  style: HapticSwipeSliderStyle.danger(
    dangerColor: const Color(0xFFEF4444),
  ),
  thumbIcon: const Icon(
    Icons.delete_forever_rounded,
    color: Colors.white,
  ),
  threshold: 0.85,
  onConfirm: () {
    print('Project deleted!');
  },
)
```

### 3. Programmatic Controller & Progress Monitoring

```dart
final HapticSwipeSliderController _controller = HapticSwipeSliderController();

// Listen to progress or state
_controller.addListener(() {
  print('Progress: ${(_controller.progress * 100).toStringAsFixed(0)}%');
  print('Current State: ${_controller.state}');
});

// Embed in widget tree
HapticSwipeSlider(
  controller: _controller,
  text: 'Slide to Authorize Transfer',
  completedText: 'Transfer Approved! ✅',
  style: HapticSwipeSliderStyle.dark(
    activeColor: const Color(0xFF10B981),
  ),
)

// Programmatic controls
_controller.complete(); // Smoothly animates to completion
_controller.reset();    // Smoothly springs back to idle
```

---

## ⚙️ Properties & Customization

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `text` | `String` | `'Slide to Confirm'` | Prompt label displayed inside track. |
| `completedText` | `String?` | `'Confirmed'` | Label displayed when state is `success`. |
| `loadingText` | `String?` | `'Processing...'` | Label displayed during async execution. |
| `onConfirm` | `FutureOr<void> Function()?` | `null` | Main trigger fired past the threshold. |
| `onCancel` | `VoidCallback?` | `null` | Triggered when released before threshold. |
| `onProgressChanged` | `ValueChanged<double>?` | `null` | Real-time progress callback (0.0 to 1.0). |
| `onStateChanged` | `ValueChanged<HapticSliderState>?` | `null` | Fired when lifecycle state transitions. |
| `controller` | `HapticSwipeSliderController?` | `null` | Programmatic lifecycle controller. |
| `style` | `HapticSwipeSliderStyle` | `HapticSwipeSliderStyle()` | Visual theme, colors, gradients, and shadows. |
| `hapticStrength` | `HapticFeedbackStrength` | `.standard` | Tactile feedback intensity profile. |
| `enableMilestoneHaptics` | `bool` | `true` | Fires tactile clicks at specified intervals. |
| `milestoneIntervals` | `List<double>` | `[0.25, 0.50, 0.75]` | Fractional milestone points for haptic ticks. |
| `threshold` | `double` | `0.82` | Drag distance ratio required to trigger confirm. |
| `height` | `double` | `56.0` | Overall height of the slider track. |
| `width` | `double?` | `null` | Custom width; expands to available width if null. |
| `padding` | `EdgeInsets` | `EdgeInsets.all(4.0)` | Margin between track bounds and thumb. |
| `thumbIcon` | `Widget?` | `arrow_forward_rounded` | Custom widget placed inside idle thumb. |
| `loadingWidget` | `Widget?` | `CircularProgressIndicator` | Custom spinner during loading state. |
| `successWidget` | `Widget?` | `check_rounded` | Custom icon displayed upon success. |
| `enableShimmer` | `bool` | `true` | Animated light reflection sweep across text. |
| `autoResetDuration` | `Duration?` | `null` | Time before resetting back to idle after success. |
| `springDuration` | `Duration` | `320ms` | Duration of the spring-back return animation. |
| `reversed` | `bool` | `false` | Enables right-to-left swipe direction. |

---

## 🖼️ Example Showcase

Explore the interactive sample application in [`example/lib/main.dart`](example/lib/main.dart) covering all 5 production scenarios.

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome! Feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/BalochCodes/haptic_swipe_slider).

---

## 📄 License

This package is licensed under the MIT License. See [LICENSE](LICENSE) for details.

Copyright (c) 2026 BalochCodes.

---

## 👨‍💻 Author

Developed with ❤️ by **Shahzain Baloch** ([BalochCodes](https://github.com/BalochCodes)).
