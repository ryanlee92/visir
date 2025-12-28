import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/mesh_loading_background.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 순차적으로 타이핑 애니메이션을 보여주는 위젯
class _SequentialTypingAnimation extends StatefulWidget {
  final bool isDark;

  const _SequentialTypingAnimation({required this.isDark});

  @override
  State<_SequentialTypingAnimation> createState() => _SequentialTypingAnimationState();
}

class _SequentialTypingAnimationState extends State<_SequentialTypingAnimation> {
  bool _isFirstComplete = false;
  bool _isSecondComplete = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 첫 번째 텍스트
        DefaultTextStyle(
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w500, color: widget.isDark ? const Color(0xFFE5E5E5) : const Color(0xFF1C1C1B), letterSpacing: -0.5),
          child: _isFirstComplete
              ? Text('Stop juggling apps.')
              : AnimatedTextKit(
                  key: const ValueKey('line1'),
                  animatedTexts: [TypewriterAnimatedText('Stop juggling apps.', speed: const Duration(milliseconds: 80), cursor: '')],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 500),
                  displayFullTextOnTap: false,
                  onFinished: () {
                    setState(() {
                      _isFirstComplete = true;
                    });
                  },
                ),
        ),
        const SizedBox(height: 8),
        // 두 번째 텍스트 (gradient 적용) - 항상 공간 확보
        SizedBox(
          height: 28, // 텍스트 높이 고정
          child: _isFirstComplete
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF818CF8), // indigo-400
                      const Color(0xFFC084FC), // purple-400
                      const Color(0xFFF472B6), // pink-400
                    ],
                  ).createShader(bounds),
                  child: DefaultTextStyle(
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5),
                    child: _isSecondComplete
                        ? Text('Reclaim your focus.')
                        : AnimatedTextKit(
                            key: ValueKey('line2_$_isFirstComplete'),
                            animatedTexts: [TypewriterAnimatedText('Reclaim your focus.', speed: const Duration(milliseconds: 80), cursor: '')],
                            totalRepeatCount: 1,
                            pause: const Duration(milliseconds: 500),
                            displayFullTextOnTap: false,
                            onFinished: () {
                              setState(() {
                                _isSecondComplete = true;
                              });
                              // 두 번째가 끝나면 잠시 후 다시 시작
                              Future.delayed(const Duration(milliseconds: 1000), () {
                                if (mounted) {
                                  setState(() {
                                    _isFirstComplete = false;
                                    _isSecondComplete = false;
                                  });
                                }
                              });
                            },
                          ),
                  ),
                )
              : const SizedBox.shrink(), // 첫 번째가 완료되기 전에는 빈 공간
        ),
      ],
    );
  }
}

/// Splash screen with Visir branding and typing animation
class SplashScreen extends StatefulWidget {
  /// Default constructor for [SplashScreen]
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: isDark ? const Color(0xFF1C1C1B) : const Color(0xFFF5F7FB),
        child: Stack(
          children: [
            // Mesh background
            Positioned.fill(child: MeshLoadingBackground(doNotAnimate: true)),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or App Name
                  Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Visir foreground logo from branding
                      Image.asset('assets/app_icon/visir_foreground.png', width: 72, height: 72),
                      const SizedBox(width: 16),
                      Text(
                        'Visir',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFE5E5E5) : const Color(0xFF1C1C1B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Typing animation text
                  _SequentialTypingAnimation(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
