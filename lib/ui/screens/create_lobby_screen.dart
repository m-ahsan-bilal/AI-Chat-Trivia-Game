// lib/ui/screens/create_lobby_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/lobby_provider.dart';
import '../../core/models/bot.dart';
import '../../core/theme/app_theme.dart';
import 'lobby_screen.dart';

class CreateLobbyScreen extends StatefulWidget {
  final String userId;

  const CreateLobbyScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _lobbyNameController = TextEditingController();

  int _maxHumans = 4;
  int _maxBots = 2;
  bool _isPrivate = false;
  bool _isCreating = false;
  final Set<String> _selectedBots = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAvailableBots();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _animationController.forward();
  }

  void _loadAvailableBots() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LobbyProvider>(context, listen: false).loadAvailableBots();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lobbyNameController.dispose();
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
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLobbyNameSection(),
                            const SizedBox(height: 24),
                            _buildCapacitySection(),
                            const SizedBox(height: 24),
                            _buildPrivacySection(),
                            const SizedBox(height: 24),
                            _buildBotSelectionSection(),
                            const SizedBox(height: 32),
                            _buildCreateButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Create New Lobby',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'AI Powered',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyNameSection() {
    return _buildSection(
      title: 'Lobby Details',
      icon: Icons.chat_bubble_outline,
      child: Column(
        children: [
          TextFormField(
            controller: _lobbyNameController,
            decoration: const InputDecoration(
              labelText: 'Lobby Name',
              hintText: 'Enter a fun lobby name...',
              prefixIcon: Icon(Icons.edit),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a lobby name';
              }
              if (value.trim().length < 3) {
                return 'Lobby name must be at least 3 characters';
              }
              if (value.trim().length > 30) {
                return 'Lobby name must be less than 30 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoColor.withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose a creative name to attract more players!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection() {
    return _buildSection(
      title: 'Capacity Settings',
      icon: Icons.people,
      child: Column(
        children: [
          _buildSliderCard(
            title: 'Maximum Players',
            subtitle: 'How many humans can join',
            value: _maxHumans.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            onChanged: (value) => setState(() => _maxHumans = value.round()),
            valueFormatter: (value) => '${value.round()} players',
            icon: Icons.person,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          _buildSliderCard(
            title: 'Maximum AI Bots',
            subtitle: 'AI companions for your lobby',
            value: _maxBots.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (value) {
              setState(() {
                _maxBots = value.round();
                if (_selectedBots.length > _maxBots) {
                  final excess = _selectedBots.length - _maxBots;
                  final botsToRemove = _selectedBots.take(excess).toList();
                  _selectedBots.removeAll(botsToRemove);
                }
              });
            },
            valueFormatter: (value) => '${value.round()} bots',
            icon: Icons.smart_toy,
            color: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) valueFormatter,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  valueFormatter(value),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              valueIndicatorColor: color,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy Settings',
      icon: _isPrivate ? Icons.lock : Icons.public,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                _isPrivate ? 'Private Lobby' : 'Public Lobby',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _isPrivate
                    ? 'Only players with invite code can join'
                    : 'Anyone can see and join this lobby',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (_isPrivate ? Colors.red : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isPrivate ? Icons.lock : Icons.public,
                  color: _isPrivate ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              activeColor: AppTheme.primaryColor,
            ),
            if (_isPrivate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'ll get an invite code to share with friends',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotSelectionSection() {
    return _buildSection(
      title: 'AI Bot Selection',
      icon: Icons.smart_toy,
      child: Consumer<LobbyProvider>(
        builder: (context, lobbyProvider, _) {
          if (lobbyProvider.availableBots.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select up to $_maxBots AI companions for your lobby',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '${_selectedBots.length}/$_maxBots',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: lobbyProvider.availableBots.length,
                itemBuilder: (context, index) {
                  final bot = lobbyProvider.availableBots[index];
                  return _buildBotCard(bot);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBotCard(Bot bot) {
    final isSelected = _selectedBots.contains(bot.name);
    final canSelect = _selectedBots.length < _maxBots || isSelected;

    return GestureDetector(
      onTap: canSelect ? () => _toggleBotSelection(bot.name) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : canSelect
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  bot.avatar,
                  style: TextStyle(
                    fontSize: 32,
                    color: canSelect ? null : Colors.grey.shade400,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bot.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: canSelect
                    ? AppTheme.textPrimaryColor
                    : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),

            Text(
              bot.description,
              style: TextStyle(
                fontSize: 11,
                color: canSelect
                    ? AppTheme.textSecondaryColor
                    : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // const SizedBox(height: 4),
            // if (bot.providerLabel.isNotEmpty)
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //     decoration: BoxDecoration(
            //       color: isSelected
            //           ? AppTheme.primaryColor.withOpacity(0.2)
            //           : Colors.grey.shade100,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Text(
            //       bot.providerLabel,
            //       style: TextStyle(
            //         fontSize: 9,
            //         color: isSelected
            //             ? AppTheme.primaryColor
            //             : Colors.grey.shade600,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Consumer<LobbyProvider>(
      builder: (context, lobbyProvider, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed:
                (_isCreating || lobbyProvider.isLoading) ? null : _createLobby,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Create Lobby',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  void _toggleBotSelection(String botName) {
    setState(() {
      if (_selectedBots.contains(botName)) {
        _selectedBots.remove(botName);
      } else if (_selectedBots.length < _maxBots) {
        _selectedBots.add(botName);
      }
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _createLobby() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

      // Create the lobby
      final lobby = await lobbyProvider.createLobby(
        name: _lobbyNameController.text.trim(),
        maxHumans: _maxHumans,
        maxBots: _maxBots,
        isPrivate: _isPrivate,
      );

      if (lobby != null) {
        // Add selected bots to the lobby
        for (final botName in _selectedBots) {
          await lobbyProvider.addBot(lobby.lobbyId, botName);
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Lobby created successfully!'),
                        if (_isPrivate)
                          Text(
                            'Invite code: ${lobby.inviteCode}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Navigate to the lobby
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LobbyScreen(
                lobbyId: lobby.lobbyId,
                lobbyName: lobby.name,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(lobbyProvider.lastError ?? 'Failed to create lobby'),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('An error occurred while creating the lobby'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
