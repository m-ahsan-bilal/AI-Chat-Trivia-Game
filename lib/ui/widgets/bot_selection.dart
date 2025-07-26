import 'package:flutter/material.dart';

class BotSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> availableBots;
  final Function(String) onBotSelected;

  const BotSelectionDialog({
    super.key,
    required this.availableBots,
    required this.onBotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.smart_toy, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text('Select AI Bot'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: availableBots.isEmpty
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading available bots...'),
                ],
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: availableBots.length,
                itemBuilder: (context, index) {
                  final bot = availableBots[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getBotColor(bot['name']),
                        child: Icon(
                          _getBotIcon(bot['name']),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        bot['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bot['personality'] ?? 'Friendly AI assistant',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getProviderColor(bot['provider']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getProviderLabel(bot['provider']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onBotSelected(bot['name']);
                      },
                      trailing:
                          const Icon(Icons.add_circle, color: Colors.green),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Color _getBotColor(String botName) {
    switch (botName.toLowerCase()) {
      case 'chatbot':
        return Colors.blue;
      case 'quizmaster':
        return Colors.orange;
      case 'cheerleader':
        return Colors.pink;
      case 'philosopher':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getBotIcon(String botName) {
    switch (botName.toLowerCase()) {
      case 'chatbot':
        return Icons.chat;
      case 'quizmaster':
        return Icons.quiz;
      case 'cheerleader':
        return Icons.celebration;
      case 'philosopher':
        return Icons.psychology;
      default:
        return Icons.smart_toy;
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'huggingface':
        return Colors.yellow.shade700;
      case 'ollama':
        return Colors.green;
      case 'enhanced_rules':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getProviderLabel(String provider) {
    switch (provider.toLowerCase()) {
      case 'huggingface':
        return 'HuggingFace AI';
      case 'ollama':
        return 'Local AI';
      case 'enhanced_rules':
        return 'Smart Rules';
      default:
        return provider.toUpperCase();
    }
  }
}
