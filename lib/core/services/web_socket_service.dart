// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';

class WebSocketService {
  // Use wss:// for WebSocket connections (not https://)
  static const String WS_BASE = 'wss://aichatapi-production.up.railway.app';

  // For HTTP requests, use https://
  static const String HTTP_BASE = 'https://aichatapi-production.up.railway.app';

  WebSocketChannel? _channel;
  Function(ChatMessage)? onMessageReceived;
  Function(bool)? onConnectionChanged;
  bool _isDisposed = false;

  bool get isConnected => _channel != null && !_isDisposed;

  void connect(String lobbyId, String userId) {
    if (_isDisposed) return;

    try {
      debugPrint('Connecting to WebSocket: $WS_BASE/ws/$lobbyId/$userId');

      _channel = WebSocketChannel.connect(
        Uri.parse('$WS_BASE/ws/$lobbyId/$userId'),
      );

      // Safely notify connection status
      _notifyConnectionStatus(true);

      _channel!.stream.listen(
        (data) {
          if (_isDisposed) return;

          debugPrint('WebSocket received: $data');
          try {
            final json = jsonDecode(data);
            final message = ChatMessage.fromJson(json);

            // Safely notify message received
            if (onMessageReceived != null && !_isDisposed) {
              onMessageReceived!(message);
            }
          } catch (e) {
            debugPrint('Error parsing message: $e');
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          debugPrint('WebSocket error: $error');
          _notifyConnectionStatus(false);
        },
        onDone: () {
          if (_isDisposed) return;
          debugPrint('WebSocket connection closed');
          _notifyConnectionStatus(false);
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _notifyConnectionStatus(false);
    }
  }

  void sendMessage(String message) {
    if (_isDisposed || _channel == null) {
      debugPrint('Cannot send message: channel not connected or disposed');
      return;
    }

    if (message.trim().isNotEmpty) {
      debugPrint('Sending message: $message');
      try {
        _channel!.sink.add(jsonEncode({'message': message}));
      } catch (e) {
        debugPrint('Error sending message: $e');
      }
    }
  }

  void disconnect() {
    if (_isDisposed) return;

    debugPrint('Disconnecting WebSocket');

    try {
      _channel?.sink.close();
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }

    _channel = null;
    _notifyConnectionStatus(false);
  }

  void _notifyConnectionStatus(bool connected) {
    if (_isDisposed) return;

    // Use a microtask to avoid calling during build
    Future.microtask(() {
      if (!_isDisposed && onConnectionChanged != null) {
        onConnectionChanged!(connected);
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    onMessageReceived = null;
    onConnectionChanged = null;
  }
}
