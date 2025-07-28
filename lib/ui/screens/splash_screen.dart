// lib/ui/screens/splash_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _backgroundOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    try {
      await _backgroundController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) await _logoController.forward();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) await _textController.forward();

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go('/app');
        // Navigator.of(context)
        //     .pushReplacementNamed('/'); // Replace with your route
      }
    } catch (e, stackTrace) {
      debugPrint('Splash animation error: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  void dispose() {
    if (_logoController.isAnimating) _logoController.stop();
    _logoController.dispose();

    if (_textController.isAnimating) _textController.stop();
    _textController.dispose();

    if (_backgroundController.isAnimating) _backgroundController.stop();
    _backgroundController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _textController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(_backgroundOpacity.value),
                  AppTheme.secondaryColor.withOpacity(_backgroundOpacity.value),
                  AppTheme.accentColor.withOpacity(
                      (_backgroundOpacity.value * 0.8).clamp(0.0, 1.0)),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _logoScale.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value * 2 * 3.1416, // full spin
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          const Text(
                            '🎮 AI Chat Trivia',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time AI-powered conversations',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading amazing features...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildChip('🤖 Powered by AI'),
                              const SizedBox(width: 12),
                              _buildChip('⚡ Real-time'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildChip("Developer: Ahsan"),
                          const SizedBox(height: 16),
                          Text(
                            'Version 2.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
