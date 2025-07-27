// lib/ui/screens/lobby_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/lobby_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/message.dart';
import '../../core/models/trivia.dart';
import '../../core/theme/app_theme.dart';

class LobbyScreen extends StatefulWidget {
  final String lobbyId;
  final String lobbyName;

  const LobbyScreen({
    super.key,
    required this.lobbyId,
    required this.lobbyName,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _connectToLobby();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    _typingAnimationController.repeat(reverse: true);
  }

  void _connectToLobby() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    await chatProvider.connectToLobby(
      widget.lobbyId,
      userProvider.currentUserId,
      userProvider.currentUsername,
    );
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();

    // Disconnect from chat
    Provider.of<ChatProvider>(context, listen: false).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildLobbyInfo(),
          _buildTriviaSection(),
          Expanded(child: _buildChatSection()),
          _buildMessageInput(),
        ],
      ),
      endDrawer: _buildLobbyDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lobbyName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return Text(
                chatProvider.isConnected ? 'Connected' : 'Connecting...',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      chatProvider.isConnected ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        Consumer<LobbyProvider>(
          builder: (context, lobbyProvider, _) {
            final lobby = lobbyProvider.currentLobby;
            if (lobby == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${lobby.currentPlayers}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyInfo() {
    return Consumer<LobbyProvider>(
      builder: (context, lobbyProvider, _) {
        final lobby = lobbyProvider.currentLobby;
        if (lobby == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      lobby.isPrivate ? Icons.lock : Icons.public,
                      size: 16,
                      color: lobby.isPrivate ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Code: ${lobby.inviteCode}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (lobby.hasActiveBots) ...[
                Row(
                  children: lobby.bots.take(3).map((bot) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Tooltip(
                        message: bot.name,
                        child: Text(
                          bot.displayAvatar,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (lobby.bots.length > 3)
                  Text(
                    ' +${lobby.bots.length - 3}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTriviaSection() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.hasActiveTrivia) {
          return _buildActiveTrivia(chatProvider.activeTrivia!);
        } else if (chatProvider.triviaResult != null) {
          return _buildTriviaResult(chatProvider.triviaResult!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActiveTrivia(TriviaQuestion trivia) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'TRIVIA TIME!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${chatProvider.triviaTimeRemaining}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            trivia.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...trivia.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;

            return Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final hasAnswered = chatProvider.hasAnsweredTrivia;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed:
                        hasAnswered ? null : () => _submitTriviaAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.secondaryColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '${String.fromCharCode(65 + index)}. $option',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            );
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTriviaResult(TriviaResult result) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withOpacity(0.2),
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
              Icon(Icons.emoji_events, color: AppTheme.successColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Trivia Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Correct Answer: ${result.correctAnswerText}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.resultSummary,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.messages.isEmpty) {
                  return Center(
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
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildTypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.username ==
        Provider.of<UserProvider>(context, listen: false).currentUsername;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  message.isBot ? AppTheme.accentColor : AppTheme.primaryColor,
              child: Text(
                message.isBot
                    ? message.avatarEmoji
                    : message.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(message),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getMessageColor(message, isCurrentUser),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply context
                    if (message.hasReply && message.repliedMessage != null)
                      _buildReplyContext(message.repliedMessage!),

                    // Sender name (for non-current users)
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              message.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: message.isBot
                                    ? AppTheme.accentColor
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            if (message.isBot) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BOT',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                    // Message content
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isCurrentUser
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                      ),
                    ),

                    // Timestamp
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrentUser
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.textTertiaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                message.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyContext(ChatMessage repliedMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: AppTheme.accentColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to ${repliedMessage.displayName}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            repliedMessage.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (!chatProvider.someoneIsTyping) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FadeTransition(
                opacity: _typingAnimation,
                child: Text(
                  '${chatProvider.typingUsers.join(', ')} ${chatProvider.typingUsers.length == 1 ? 'is' : 'are'} typing...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _typingAnimationController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final animationValue =
                            (_typingAnimationController.value - delay)
                                .clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(0, -4 * animationValue),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppTheme.textSecondaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Reply banner
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (!chatProvider.isReplying) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${chatProvider.replyingTo!.displayName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          Text(
                            chatProvider.replyingTo!.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false)
                            .clearReply();
                      },
                      icon: const Icon(Icons.close, size: 16),
                      color: AppTheme.textSecondaryColor,
                    ),
                  ],
                ),
              );
            },
          ),

          // Message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: _onMessageChanged,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: chatProvider.isConnected ? _sendMessage : null,
                      icon: const Icon(Icons.send, color: Colors.white),
                      splashRadius: 24,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Lobby Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<LobbyProvider>(
                builder: (context, lobbyProvider, _) {
                  final lobby = lobbyProvider.currentLobby;
                  if (lobby == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    children: [
                      _buildLobbyInfoTile(lobby),
                      const Divider(),
                      _buildParticipantsList(lobby),
                      const Divider(),
                      _buildBotManagement(lobby),
                      const Divider(),
                      _buildLobbyActions(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyInfoTile(lobby) {
    return ListTile(
      leading: Icon(
        lobby.isPrivate ? Icons.lock : Icons.public,
        color: lobby.isPrivate ? Colors.red : Colors.green,
      ),
      title: Text(lobby.name),
      subtitle: Text('Code: ${lobby.inviteCode}'),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: lobby.inviteCode));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite code copied!')),
          );
        },
      ),
    );
  }

  Widget _buildParticipantsList(lobby) {
    return ExpansionTile(
      leading: const Icon(Icons.people),
      title: Text('Participants (${lobby.currentPlayers})'),
      children: [
        ...lobby.users
            .map((user) => ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(user),
                  trailing: lobby.activeUsers.contains(user)
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildBotManagement(lobby) {
    return ExpansionTile(
      leading: const Icon(Icons.smart_toy),
      title: Text('AI Bots (${lobby.currentBots}/${lobby.maxBots})'),
      children: [
        ...lobby.bots
            .map((bot) => ListTile(
                  leading: Text(bot.displayAvatar,
                      style: const TextStyle(fontSize: 20)),
                  title: Text(bot.name),
                  subtitle: Text(bot.description ?? 'AI Assistant'),
                  trailing: IconButton(
                    onPressed: () => _removeBot(bot.name),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ))
            .toList(),
        if (lobby.currentBots < lobby.maxBots)
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.green),
            title: const Text('Add Bot'),
            onTap: _showAddBotDialog,
          ),
      ],
    );
  }

  Widget _buildLobbyActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.refresh, color: Colors.blue),
          title: const Text('Refresh'),
          onTap: _refreshLobby,
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text('Leave Lobby'),
          onTap: _showLeaveLobbyDialog,
        ),
      ],
    );
  }

  // Helper methods
  Color _getMessageColor(ChatMessage message, bool isCurrentUser) {
    if (isCurrentUser) {
      return AppTheme.primaryColor;
    } else if (message.isBot) {
      return AppTheme.accentColor.withOpacity(0.1);
    } else if (message.isSystem) {
      return Colors.grey.shade200;
    }
    return Colors.white;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _onMessageChanged(String text) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (text.isEmpty && _isTyping) {
      _isTyping = false;
      chatProvider.sendTyping(false);
      _typingTimer?.cancel();
    } else if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatProvider.sendTyping(true);
    }

    // Stop typing after 2 seconds of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        chatProvider.sendTyping(false);
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.sendMessage(message);

    if (success) {
      _messageController.clear();
      _isTyping = false;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  void _submitTriviaAnswer(int answerIndex) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.submitTriviaAnswer(answerIndex);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit answer')),
      );
    }
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ChatProvider>(context, listen: false)
                    .setReplyTo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBotDialog() {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add AI Bot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: lobbyProvider.availableBots.map((bot) {
            return ListTile(
              leading: Text(bot.avatar, style: const TextStyle(fontSize: 24)),
              title: Text(bot.name),
              subtitle: Text(bot.description),
              onTap: () async {
                Navigator.pop(context);
                _addBot(bot.name);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addBot(String botName) async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    final success = await lobbyProvider.addBot(widget.lobbyId, botName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(success ? 'Bot added successfully!' : 'Failed to add bot'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _removeBot(String botName) async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    final success = await lobbyProvider.removeBot(widget.lobbyId, botName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Bot removed successfully!' : 'Failed to remove bot'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _refreshLobby() async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    await lobbyProvider.fetchLobbyInfo(widget.lobbyId);

    if (mounted) {
      Navigator.pop(context); // Close drawer
    }
  }

  void _showLeaveLobbyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Lobby'),
        content: const Text('Are you sure you want to leave this lobby?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _leaveLobby();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _leaveLobby() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    final success = await lobbyProvider.leaveLobby(
      widget.lobbyId,
      userProvider.currentUserId,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(); // Return to home screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to leave lobby')),
        );
      }
    }
  }
}
