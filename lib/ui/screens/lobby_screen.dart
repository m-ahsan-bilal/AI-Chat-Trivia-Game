// lib/screens/lobby_screen.dart
import 'package:ai_chat_trivia/core/models/message.dart';
import 'package:ai_chat_trivia/core/providers/chat_provider.dart';
import 'package:ai_chat_trivia/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_chat_trivia/core/providers/lobby_provider.dart';
import 'package:ai_chat_trivia/core/models/trivia.dart';
import 'package:ai_chat_trivia/core/models/lobby.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize chat provider
    _chatProvider = ChatProvider();

    // Connect to lobby after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
      await lobbyProvider.fetchLobbyInfo(widget.lobbyId);
      await Future.delayed(
          const Duration(milliseconds: 500)); // Delay to avoid race condition
      if (userProvider.currentUser != null) {
        _chatProvider.connectToLobby(
          widget.lobbyId,
          userProvider.currentUser!.userId,
        );
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
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: chatProvider.isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chatProvider.isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
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
                  if (chatProvider.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
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
        final fallbackLobby = Lobby(
          lobbyId: '',
          name: '',
          currentPlayers: 0,
          maxHumans: 0,
          isPrivate: false,
          inviteCode: '-',
          users: const [],
          bots: const [],
          messageCount: 0,
          triviaActive: false,
        );
        final lobby = lobbyProvider.lobbies.firstWhere(
          (l) => l.lobbyId == widget.lobbyId,
          orElse: () => fallbackLobby,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 18),
                  const SizedBox(width: 4),
                  Text('Users: ${lobbyProvider.users.join(", ")}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.smart_toy, size: 18),
                  const SizedBox(width: 4),
                  Text('Bots: ${lobbyProvider.bots.join(", ")}'),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    tooltip: 'Add Bot',
                    onPressed: () async {
                      final availableBots =
                          await lobbyProvider.apiService.getAvailableBots();
                      if (availableBots.isNotEmpty) {
                        final selectedBot = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: const Text('Select Bot to Add'),
                              children: availableBots.map((bot) {
                                return SimpleDialogOption(
                                  child: Text(bot),
                                  onPressed: () => Navigator.pop(context, bot),
                                );
                              }).toList(),
                            );
                          },
                        );
                        if (selectedBot != null) {
                          await lobbyProvider.addBot(
                              widget.lobbyId, selectedBot);
                        }
                      }
                    },
                  ),
                  if (lobbyProvider.bots.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove Bot',
                      onSelected: (bot) async {
                        await lobbyProvider.removeBot(widget.lobbyId, bot);
                      },
                      itemBuilder: (context) => lobbyProvider.bots
                          .map((bot) => PopupMenuItem(
                                value: bot,
                                child: Text('Remove $bot'),
                              ))
                          .toList(),
                    ),
                  const SizedBox(width: 12),
                  if (lobbyProvider.triviaActive)
                    const Icon(Icons.quiz, color: Colors.deepPurple, size: 18),
                  if (lobbyProvider.triviaActive) const SizedBox(width: 4),
                  if (lobbyProvider.triviaActive)
                    const Text('Trivia Active',
                        style: TextStyle(color: Colors.deepPurple)),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text('Invite Code: ${lobby.inviteCode}'),
                  const SizedBox(width: 12),
                  Icon(
                    lobby.isPrivate ? Icons.lock : Icons.public,
                    size: 16,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(lobby.isPrivate ? 'Private' : 'Public'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTriviaQuestion(TriviaQuestion trivia) {
    int? selectedOption;
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Card(
          color: Colors.yellow.shade50,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trivia Time!',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(trivia.question, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                ...List.generate(trivia.options.length, (i) {
                  return RadioListTile<int>(
                    value: i,
                    groupValue: selectedOption,
                    title: Text(trivia.options[i]),
                    onChanged: (val) async {
                      selectedOption = val;
                      if (val != null) {
                        await Provider.of<ChatProvider>(context, listen: false)
                            .submitTriviaAnswer(widget.lobbyId,
                                userProvider.currentUser!.userId, val);
                        setState(() {});
                      }
                    },
                  );
                }),
                const SizedBox(height: 4),
                const Text('Submit your answer before time runs out!'),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trivia Result',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Correct answer: Option ${result.correctAnswer + 1}'),
            const SizedBox(height: 4),
            if (result.winners.isNotEmpty)
              Text('Winners: ${result.winners.join(", ")}',
                  style: const TextStyle(color: Colors.green)),
            if (result.winners.isEmpty)
              const Text('No winners this round.',
                  style: TextStyle(color: Colors.red)),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isBot ? Colors.deepPurple : Colors.blue.shade600,
              child: isBot
                  ? const Icon(Icons.smart_toy, color: Colors.white, size: 18)
                  : Text(
                      message.username[0].toUpperCase(),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.deepPurple.shade100
                    : (isCurrentUser
                        ? Colors.blue.shade600
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Row(
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
                        if (isBot)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.smart_toy,
                                size: 14, color: Colors.deepPurple),
                          ),
                      ],
                    ),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isBot
                          ? Colors.deepPurple.shade900
                          : (isCurrentUser ? Colors.white : Colors.black87),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade600,
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -1),
            blurRadius: 4,
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
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return FloatingActionButton(
                mini: true,
                onPressed: chatProvider.isConnected ? _sendMessage : null,
                child: const Icon(Icons.send),
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
}
