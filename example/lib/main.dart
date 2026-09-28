import 'package:flutter/material.dart';
import 'package:haptic_swipe_slider/haptic_swipe_slider.dart';

void main() {
  runApp(const HapticSwipeSliderExampleApp());
}

class HapticSwipeSliderExampleApp extends StatelessWidget {
  const HapticSwipeSliderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haptic Swipe Slider Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF131927),
        ),
        useMaterial3: true,
      ),
      home: const SliderShowcaseScreen(),
    );
  }
}

class SliderShowcaseScreen extends StatefulWidget {
  const SliderShowcaseScreen({super.key});

  @override
  State<SliderShowcaseScreen> createState() => _SliderShowcaseScreenState();
}

class _SliderShowcaseScreenState extends State<SliderShowcaseScreen> {
  final HapticSwipeSliderController _programmaticController =
      HapticSwipeSliderController();
  double _controllerProgress = 0.0;
  HapticSliderState _controllerState = HapticSliderState.idle;

  @override
  void initState() {
    super.initState();
    _programmaticController.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {
      _controllerProgress = _programmaticController.progress;
      _controllerState = _programmaticController.state;
    });
  }

  @override
  void dispose() {
    _programmaticController.removeListener(_onControllerUpdate);
    _programmaticController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Haptic Swipe Slider',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F1422),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionHeader(
              title: '1. Fintech Checkout',
              subtitle: 'Async order processing, milestone ticks, and success badge',
            ),
            const SizedBox(height: 12),
            HapticSwipeSlider(
              text: 'Slide to Pay \$249.00',
              completedText: 'Payment Confirmed! 💳',
              loadingText: 'Processing Payment...',
              style: HapticSwipeSliderStyle.dark(
                activeColor: const Color(0xFF6366F1),
              ),
              thumbIcon: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF6366F1),
              ),
              autoResetDuration: const Duration(seconds: 3),
              onConfirm: () async {
                // Simulate network payment request
                await Future.delayed(const Duration(milliseconds: 1400));
              },
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(
              title: '2. Smart Home Unlock',
              subtitle: 'Neon cyber glow with spring-back physics',
            ),
            const SizedBox(height: 12),
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
                await Future.delayed(const Duration(milliseconds: 1000));
              },
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(
              title: '3. Destructive Action',
              subtitle: 'Danger red palette with custom delete confirmation',
            ),
            const SizedBox(height: 12),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project permanent deletion verified.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(
              title: '4. Programmatic Controller',
              subtitle: 'Inspect live drag percentage and trigger states externally',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131927),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${(_controllerProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStateColor(_controllerState).withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStateColor(_controllerState),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _controllerState.name.toUpperCase(),
                          style: TextStyle(
                            color: _getStateColor(_controllerState),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HapticSwipeSlider(
                    controller: _programmaticController,
                    text: 'Slide to Authorize Transfer',
                    completedText: 'Transfer Approved! ✅',
                    style: HapticSwipeSliderStyle.dark(
                      activeColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset'),
                        onPressed: () => _programmaticController.reset(),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Complete'),
                        onPressed: () => _programmaticController.complete(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(
              title: '5. Clean Light Pill',
              subtitle: 'Minimalist aesthetic for bright interfaces',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: HapticSwipeSlider(
                text: 'Slide to Send Money',
                completedText: 'Sent! 🚀',
                style: HapticSwipeSliderStyle.light(
                  activeColor: const Color(0xFF2563EB),
                ),
                thumbIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF2563EB),
                ),
                autoResetDuration: const Duration(seconds: 2),
                onConfirm: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Color _getStateColor(HapticSliderState state) {
    switch (state) {
      case HapticSliderState.idle:
        return const Color(0xFF94A3B8);
      case HapticSliderState.dragging:
        return const Color(0xFF38BDF8);
      case HapticSliderState.loading:
        return const Color(0xFFFBBF24);
      case HapticSliderState.success:
        return const Color(0xFF34D399);
      case HapticSliderState.error:
        return const Color(0xFFF87171);
    }
  }
}
