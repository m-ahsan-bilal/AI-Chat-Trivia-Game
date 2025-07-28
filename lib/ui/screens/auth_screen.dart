// lib/ui/screens/auth_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _isLogin = true;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRegisteredUsers();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _cardAnimationController.forward();
  }

  void _loadRegisteredUsers() async {
    // This will help populate suggestions for login
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.getRegisteredUsernames();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor.withOpacity(0.6),
              AppTheme.accentColor.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildAuthCard(),
                      const SizedBox(height: 20),
                      _buildToggleButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'AI Trivia Chat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge AI bots and friends in trivia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(),
                const SizedBox(height: 30),
                _buildUsernameField(),
                const SizedBox(height: 24),
                if (!_isLogin) _buildUsernameSuggestions(),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Sign in to continue your trivia journey'
              : 'Join the AI trivia community',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return TextFormField(
          controller: _usernameController,
          enabled: !userProvider.isLoading,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: _usernameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _usernameController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() {}),
          onFieldSubmitted: (_) => _handleSubmit(),
          validator: UserProvider.validateUsername,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      },
    );
  }

  Widget _buildUsernameSuggestions() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return FutureBuilder<List<String>>(
          future: userProvider.getRegisteredUsernames(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered users:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: snapshot.data!.take(5).map((username) {
                    return ActionChip(
                      label: Text(username),
                      onPressed: () {
                        _usernameController.text = username;
                        _isLogin = true;
                        setState(() {});
                      },
                      backgroundColor:
                          AppTheme.primaryLightColor.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isLoading = userProvider.isLoading;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLogin ? Icons.login : Icons.person_add,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLogin ? "Don't have an account? " : "Already have an account? ",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isLogin = !_isLogin;
              });
              // Add a subtle animation when toggling
              _cardAnimationController.reset();
              _cardAnimationController.forward();
            },
            child: Text(
              _isLogin ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.errorColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userProvider.lastError!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: AppTheme.errorColor,
                onPressed: userProvider.clearError,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = _usernameController.text.trim();

    bool success;
    if (_isLogin) {
      success = await userProvider.loginUser(username);
    } else {
      success = await userProvider.registerUser(username);
    }

    if (success) {
      if (mounted) {
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _isLogin
                      ? 'Welcome back, $username!'
                      : 'Account created successfully!',
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      // Error is handled by the provider and shown in _buildErrorMessage
      // Add haptic feedback for error
      HapticFeedback.lightImpact();
    }
  }
}

// Additional helper widgets for enhanced UX
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
