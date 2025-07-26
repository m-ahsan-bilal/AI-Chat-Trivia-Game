// lib/widgets/lobby_card.dart
import 'package:ai_chat_trivia/core/models/lobby.dart';
import 'package:flutter/material.dart';

class LobbyCard extends StatelessWidget {
  final Lobby lobby;
  final VoidCallback onTap;

  const LobbyCard({
    super.key,
    required this.lobby,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lobby.isPrivate ? Colors.red[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  lobby.isPrivate ? Icons.lock : Icons.public,
                  color: lobby.isPrivate ? Colors.red[600] : Colors.blue[600],
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${lobby.currentPlayers}/${lobby.maxHumans}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.vpn_key, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          lobby.inviteCode,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
