// lib/ui/screens/home_screen.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/models/lobby.dart';
import '../../core/providers/lobby_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import 'create_lobby_screen.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _inviteCodeController = TextEditingController();
  final _searchController = TextEditingController();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  Timer? _searchDebounce;
  String _searchQuery = '';

  // Filter states
  bool _showPublicOnly = false;
  bool _showAvailableOnly = true;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeScreen();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
      lobbyProvider.loadLobbies();
      lobbyProvider.loadServerStats();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _inviteCodeController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildWelcomeSection()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildSearchAndFilters()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            _buildLobbyList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Future<void> _refreshData() async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    await Future.wait([
      lobbyProvider.loadLobbies(),
      lobbyProvider.loadServerStats(),
    ]);
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: const Text(
          'AI Trivia Lobbies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              icon: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        userProvider.currentUsername[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.currentUsername,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppTheme.secondaryColor),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'stats',
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: AppTheme.accentColor),
                      SizedBox(width: 12),
                      Text('Server Stats'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppTheme.errorColor),
                      SizedBox(width: 12),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${userProvider.currentUsername}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready for some AI trivia challenges?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              title: 'Join with Code',
              subtitle: 'Have an invite code?',
              icon: Icons.vpn_key,
              color: AppTheme.accentColor,
              onTap: _showJoinByCodeDialog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              title: 'Quick Match',
              subtitle: 'Join any lobby',
              icon: Icons.flash_on,
              color: AppTheme.successColor,
              onTap: _quickMatch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search lobbies...',
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.textSecondaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textSecondaryColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Available Only',
                  icon: Icons.door_front_door,
                  isSelected: _showAvailableOnly,
                  onSelected: (selected) {
                    setState(() => _showAvailableOnly = selected);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Public Only',
                  icon: Icons.public,
                  isSelected: _showPublicOnly,
                  onSelected: (selected) {
                    setState(() => _showPublicOnly = selected);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active Only',
                  icon: Icons.online_prediction,
                  isSelected: _showActiveOnly,
                  onSelected: (selected) {
                    setState(() => _showActiveOnly = selected);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor.withOpacity(0.1),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<LobbyProvider>(
      builder: (context, lobbyProvider, _) {
        final stats = lobbyProvider.getLobbyStatistics();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.secondaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Live Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Total', '${stats['total']}',
                        Icons.chat_bubble_outline),
                  ),
                  Expanded(
                    child: _buildStatItem('Active', '${stats['active']}',
                        Icons.online_prediction),
                  ),
                  Expanded(
                    child: _buildStatItem('Available', '${stats['available']}',
                        Icons.door_front_door),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyList() {
    return Consumer<LobbyProvider>(
      builder: (context, lobbyProvider, _) {
        if (lobbyProvider.isLoading && lobbyProvider.lobbies.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Loading lobbies...',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final filteredLobbies = _getFilteredLobbies(lobbyProvider.lobbies);

        if (filteredLobbies.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No lobbies match your search'
                        : 'No lobbies available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try adjusting your filters or search terms'
                        : 'Create the first lobby to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateLobby,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Lobby'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              20, 0, 20, 80), // Bottom padding for FAB
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < filteredLobbies.length) {
                  return _buildLobbyCard(filteredLobbies[index]);
                }
                return null;
              },
              childCount: filteredLobbies.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLobbyCard(Lobby lobby) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _joinLobby(lobby),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: lobby.isPrivate
                            ? LinearGradient(colors: [
                                Colors.red.shade400,
                                Colors.red.shade600
                              ])
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        lobby.isPrivate ? Icons.lock : Icons.public,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lobby.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.vpn_key,
                                  size: 14, color: AppTheme.textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                lobby.inviteCode,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (lobby.hasTriviaActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade600
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.quiz, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLobbyMetric(
                      icon: Icons.people,
                      label: 'Players',
                      value: '${lobby.currentPlayers}/${lobby.maxHumans}',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 20),
                    _buildLobbyMetric(
                      icon: Icons.smart_toy,
                      label: 'Bots',
                      value: '${lobby.currentBots}/${lobby.maxBots}',
                      color: AppTheme.accentColor,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: lobby.isActive
                            ? AppTheme.successColor.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lobby.isActive
                              ? AppTheme.successColor.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        lobby.statusDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: lobby.isActive
                              ? AppTheme.successColor
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                if (lobby.hasActiveBots) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.psychology,
                          size: 16, color: AppTheme.textSecondaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Bots: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      ...lobby.bots
                          .take(3)
                          .map((bot) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Tooltip(
                                  message: bot.name,
                                  child: Text(
                                    bot.displayAvatar,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ))
                          // ignore: unnecessary_to_list_in_spreads
                          .toList(),
                      if (lobby.bots.length > 3)
                        Text(
                          ' +${lobby.bots.length - 3} more',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLobbyMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _navigateToCreateLobby,
        icon: const Icon(Icons.add),
        label: const Text('Create Lobby'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Helper methods
  List<Lobby> _getFilteredLobbies(List<Lobby> lobbies) {
    var filtered = lobbies;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((lobby) =>
              lobby.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              lobby.inviteCode
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply other filters
    if (_showPublicOnly) {
      filtered = filtered.where((lobby) => !lobby.isPrivate).toList();
    }

    if (_showAvailableOnly) {
      filtered = filtered.where((lobby) => !lobby.isFull).toList();
    }

    if (_showActiveOnly) {
      filtered = filtered.where((lobby) => lobby.isActive).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query);
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        _showUserProfile();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'stats':
        _showServerStats();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  void _showJoinByCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.vpn_key,
                  color: AppTheme.accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Join with Invite Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _inviteCodeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'Enter 6-character code',
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              onSubmitted: (_) => _joinLobbyWithCode(fromDialog: true),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Get invite codes from friends or lobby creators',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _inviteCodeController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _joinLobbyWithCode(fromDialog: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _quickMatch() async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    // Find the best available lobby
    final availableLobbies = lobbyProvider.lobbies
        .where((lobby) => !lobby.isFull && !lobby.isPrivate)
        .toList();

    if (availableLobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('No available lobbies for quick match'),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Create One',
            textColor: Colors.white,
            onPressed: _navigateToCreateLobby,
          ),
        ),
      );
      return;
    }

    // Sort by activity and player count
    availableLobbies.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return b.currentPlayers.compareTo(a.currentPlayers);
    });

    final bestLobby = availableLobbies.first;
    _joinLobby(bestLobby);
  }

  void _joinLobbyWithCode({bool fromDialog = false}) async {
    final inviteCode = _inviteCodeController.text.trim().toUpperCase();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Please enter an invite code'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (fromDialog) Navigator.pop(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await lobbyProvider.joinLobbyByInvite(
      inviteCode,
      userProvider.currentUserId,
    );

    Navigator.pop(context); // Close loading dialog

    if (success) {
      await lobbyProvider.loadLobbies();
      final lobby = lobbyProvider.lobbies.cast<Lobby?>().firstWhere(
            (l) => l?.inviteCode == inviteCode,
            orElse: () => null,
          );

      if (lobby != null) {
        _navigateToLobby(lobby.lobbyId, lobby.name);
        _inviteCodeController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(lobbyProvider.lastError ?? 'Failed to join lobby'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _joinLobby(Lobby lobby) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success;
    if (lobby.isPrivate) {
      success = await lobbyProvider.joinLobbyByInvite(
        lobby.inviteCode,
        userProvider.currentUserId,
      );
    } else {
      success = await lobbyProvider.joinPublicLobby(
        lobby.lobbyId,
        userProvider.currentUserId,
      );
    }

    Navigator.pop(context); // Close loading dialog

    if (success) {
      _navigateToLobby(lobby.lobbyId, lobby.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                lobby.isFull
                    ? 'Lobby is full'
                    : lobbyProvider.lastError ?? 'Failed to join lobby',
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToCreateLobby() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateLobbyScreen(userId: userProvider.currentUserId),
      ),
    );

    // Refresh lobby list after returning
    if (mounted) {
      Provider.of<LobbyProvider>(context, listen: false).loadLobbies();
    }
  }

  void _navigateToLobby(String lobbyId, String lobbyName) async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    await lobbyProvider.fetchLobbyInfo(lobbyId);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            lobbyId: lobbyId,
            lobbyName: lobbyName,
          ),
        ),
      );
    }
  }

  void _showUserProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                userProvider.currentUsername[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.currentUsername,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${userProvider.currentUserId}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark themes'),
              value: userProvider.isDarkMode,
              onChanged: (value) => userProvider.setDarkMode(value),
              secondary: Icon(
                userProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primaryColor,
              ),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: userProvider.notificationsEnabled,
              onChanged: (value) => userProvider.setNotificationsEnabled(value),
              secondary: const Icon(Icons.notifications,
                  color: AppTheme.secondaryColor),
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Play sounds for messages and events'),
              value: userProvider.soundEnabled,
              onChanged: (value) => userProvider.setSoundEnabled(value),
              secondary:
                  const Icon(Icons.volume_up, color: AppTheme.accentColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServerStats() async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await lobbyProvider.loadServerStats();
    final stats = lobbyProvider.serverStats;

    Navigator.pop(context); // Close loading dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics,
                  color: AppTheme.accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Server Statistics'),
          ],
        ),
        content: stats != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                        'Total Users', '${stats['total_users'] ?? 0}'),
                    _buildStatRow(
                        'Total Lobbies', '${stats['total_lobbies'] ?? 0}'),
                    _buildStatRow(
                        'Active Lobbies', '${stats['active_lobbies'] ?? 0}'),
                    _buildStatRow(
                        'Total Messages', '${stats['total_messages'] ?? 0}'),
                    _buildStatRow('Total Bots', '${stats['total_bots'] ?? 0}'),
                    const SizedBox(height: 16),
                    const Text(
                      'AI Providers:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (stats['ai_providers'] != null) ...[
                      _buildProviderStatus('HuggingFace',
                          stats['ai_providers']['huggingface'] ?? false),
                      _buildProviderStatus(
                          'Ollama', stats['ai_providers']['ollama'] ?? false),
                      _buildProviderStatus('Enhanced Rules',
                          stats['ai_providers']['enhanced_rules'] ?? false),
                    ],
                  ],
                ),
              )
            : const Text('Failed to load server statistics'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStatus(String name, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.check_circle : Icons.error,
            size: 16,
            color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout,
                  color: AppTheme.errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<UserProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
