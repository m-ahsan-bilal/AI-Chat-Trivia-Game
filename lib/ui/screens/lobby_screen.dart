// lib/screens/lobby_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:ai_chat_trivia/core/models/message.dart';
import 'package:ai_chat_trivia/core/providers/chat_provider.dart';
import 'package:ai_chat_trivia/core/providers/user_provider.dart';
import 'package:ai_chat_trivia/ui/widgets/bot_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_chat_trivia/core/providers/lobby_provider.dart';
import 'package:ai_chat_trivia/core/models/trivia.dart';

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

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatProvider _chatProvider;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();

    // Initialize chat provider
    _chatProvider = ChatProvider();

    // Connect to lobby after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

      try {
        await lobbyProvider.fetchLobbyInfo(widget.lobbyId);
        await Future.delayed(const Duration(milliseconds: 500));

        if (userProvider.currentUser != null) {
          _chatProvider.connectToLobby(
            widget.lobbyId,
            userProvider.currentUser!.userId,
          );
        }
      } catch (e) {
        debugPrint('Error initializing lobby: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _chatProvider.disconnect();
    _chatProvider.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatProvider>.value(value: _chatProvider),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lobbyName),
          actions: [
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _isConnecting
                        ? Colors.orange
                        : (chatProvider.isConnected
                            ? Colors.green
                            : Colors.red),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isConnecting
                        ? 'Connecting...'
                        : (chatProvider.isConnected
                            ? 'Connected'
                            : 'Disconnected'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'leave') {
                  _showLeaveLobbyDialog();
                } else if (value == 'info') {
                  _showLobbyInfoDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Lobby Info'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Leave Lobby'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _buildLobbyInfoSection(),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.hasActiveTrivia &&
                    chatProvider.activeTrivia != null) {
                  return _buildTriviaQuestion(chatProvider.activeTrivia!);
                } else if (chatProvider.triviaResult != null) {
                  return _buildTriviaResult(chatProvider.triviaResult!);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  if (_isConnecting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Connecting to lobby...'),
                        ],
                      ),
                    );
                  }

                  if (chatProvider.messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet. Start the conversation!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Say hi to get the AI bots talking! 🤖',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Auto-scroll to bottom when new messages arrive
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
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyInfoSection() {
    return Consumer<LobbyProvider>(
      builder: (context, lobbyProvider, _) {
        return Column(
          children: [
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('${lobbyProvider.activeUsers.length} active'),
                        const SizedBox(width: 16),
                        const Icon(Icons.smart_toy,
                            size: 18, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        Text('${lobbyProvider.bots.length} bots'),
                        if (lobbyProvider.triviaActive) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.quiz,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          const Text('Trivia Active',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                  _buildBotManagementButtons(lobbyProvider),
                ],
              ),
            ),
            if (lobbyProvider.bots.isNotEmpty)
              Container(
                color: Colors.deepPurple.shade50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy,
                        size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Text('Active Bots: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: lobbyProvider.bots
                            .map((bot) => Chip(
                                  label: Text(bot,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor: Colors.deepPurple.shade100,
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      _removeBot(bot, lobbyProvider),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBotManagementButtons(LobbyProvider lobbyProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          tooltip: 'Add AI Bot',
          onPressed: () => _showAddBotDialog(lobbyProvider),
        ),
        if (lobbyProvider.bots.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            tooltip: 'Refresh Lobby Info',
            onPressed: () => lobbyProvider.fetchLobbyInfo(widget.lobbyId),
          ),
      ],
    );
  }

  void _showAddBotDialog(LobbyProvider lobbyProvider) async {
    try {
      final availableBots = await lobbyProvider.getAvailableBots();

      if (!mounted) return;

      if (availableBots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No bots available at the moment')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => BotSelectionDialog(
          availableBots: availableBots,
          onBotSelected: (botName) => _addBot(botName, lobbyProvider),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bots: $e')),
      );
    }
  }

  void _addBot(String botName, LobbyProvider lobbyProvider) async {
    final success = await lobbyProvider.addBot(widget.lobbyId, botName);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$botName added to the lobby! 🤖'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add $botName. Lobby might be full.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeBot(String botName, LobbyProvider lobbyProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove $botName?'),
        content:
            Text('Are you sure you want to remove $botName from the lobby?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await lobbyProvider.removeBot(widget.lobbyId, botName);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$botName removed from the lobby'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove $botName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTriviaQuestion(TriviaQuestion trivia) {
    int? selectedOption;
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Card(
          color: Colors.orange.shade50,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Trivia Time!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${trivia.timeLimit}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trivia.question,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ...List.generate(trivia.options.length, (i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        selectedOption = i;
                        await Provider.of<ChatProvider>(context, listen: false)
                            .submitTriviaAnswer(
                          widget.lobbyId,
                          userProvider.currentUser!.userId,
                          i,
                        );
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedOption == i
                              ? Colors.orange.shade200
                              : Colors.white,
                          border: Border.all(
                            color: selectedOption == i
                                ? Colors.orange
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selectedOption == i
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: selectedOption == i
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                trivia.options[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedOption == i
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (selectedOption == i)
                              const Icon(Icons.check, color: Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  '⏰ Submit your answer before time runs out!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTriviaResult(TriviaResult result) {
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'Trivia Result',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Correct answer: Option ${result.correctAnswer + 1}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (result.winners.isNotEmpty) ...[
              const Text(
                '🏆 Winners:',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: result.winners
                    .map((winner) => Chip(
                          label: Text(winner),
                          backgroundColor: Colors.green.shade100,
                          avatar: const Icon(Icons.star,
                              size: 16, color: Colors.green),
                        ))
                    .toList(),
              ),
            ] else ...[
              const Text(
                '😅 No winners this round - better luck next time!',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSystem = message.type == 'system';
    final isBot =
        message.type == 'bot' || message.username.toLowerCase().contains('bot');
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    final isCurrentUser = message.username == currentUser?.username;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: isBot ? Colors.deepPurple : Colors.blue.shade600,
              child: isBot
                  ? const Icon(Icons.smart_toy, color: Colors.white, size: 20)
                  : Text(
                      message.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.deepPurple.shade100
                    : (isCurrentUser
                        ? Colors.blue.shade600
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 6),
                  bottomRight: Radius.circular(isCurrentUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.username,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isBot
                                ? Colors.deepPurple
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (isBot) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.smart_toy,
                            size: 12,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ],
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isBot
                          ? Colors.deepPurple.shade900
                          : (isCurrentUser ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade600,
              child: Text(
                message.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return FloatingActionButton(
                mini: true,
                onPressed: chatProvider.isConnected && !_isConnecting
                    ? _sendMessage
                    : null,
                backgroundColor: chatProvider.isConnected && !_isConnecting
                    ? Colors.blue.shade600
                    : Colors.grey,
                child: const Icon(Icons.send, color: Colors.white),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatProvider.sendMessage(message);
      _messageController.clear();
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
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showLobbyInfoDialog() {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.lobbyName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lobby ID: ${widget.lobbyId}'),
            Text('Active Users: ${lobbyProvider.activeUsers.join(", ")}'),
            Text('Total Users: ${lobbyProvider.users.join(", ")}'),
            Text('Active Bots: ${lobbyProvider.bots.join(", ")}'),
            Text('Messages: ${lobbyProvider.messageCount}'),
            Text('Trivia Active: ${lobbyProvider.triviaActive ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
