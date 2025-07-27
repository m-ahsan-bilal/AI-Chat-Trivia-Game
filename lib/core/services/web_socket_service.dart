// lib/core/services/web_socket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';

class WebSocketService {
  static const String WS_BASE = 'wss://aichatapi-production.up.railway.app';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  // Callbacks
  Function(ChatMessage)? onMessageReceived;
  Function(bool)? onConnectionChanged;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onTypingReceived;

  // State
  bool _isDisposed = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(seconds: 30);

  // Connection info
  String? _currentLobbyId;
  String? _currentUserId;

  bool get isConnected => _channel != null && !_isDisposed;
  bool get isConnecting => _isConnecting;

  /// Connect to a lobby's WebSocket
  void connect(String lobbyId, String userId) {
    if (_isDisposed) return;

    _currentLobbyId = lobbyId;
    _currentUserId = userId;
    _shouldReconnect = true;
    _reconnectAttempts = 0;

    _connectInternal();
  }

  void _connectInternal() {
    if (_isDisposed || _isConnecting) return;

    _isConnecting = true;
    _notifyConnectionStatus(false);

    try {
      final wsUrl = '$WS_BASE/ws/$_currentLobbyId/$_currentUserId';
      debugPrint('🔌 Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Send initial ping to confirm connection
      _sendPing();
      _startPingTimer();

      _isConnecting = false;
      _reconnectAttempts = 0;
      _notifyConnectionStatus(true);

      debugPrint('✅ WebSocket connected successfully');
    } catch (e) {
      _isConnecting = false;
      debugPrint('❌ WebSocket connection error: $e');
      _handleError(e);
    }
  }

  void _handleMessage(dynamic data) {
    if (_isDisposed) return;

    try {
      debugPrint('📥 WebSocket received: $data');
      final json = jsonDecode(data);

      // Handle different message types
      switch (json['type']) {
        case 'pong':
          debugPrint('🏓 Received pong');
          break;

        case 'typing':
          if (onTypingReceived != null) {
            onTypingReceived!(json);
          }
          break;

        case 'error':
          debugPrint('❌ Server error: ${json['message']}');
          if (onError != null) {
            onError!(json['message'] ?? 'Unknown server error');
          }
          break;

        default:
          // Regular chat message
          final message = ChatMessage.fromJson(json);
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
          break;
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
      debugPrint('Raw data: $data');
    }
  }

  void _handleError(dynamic error) {
    if (_isDisposed) return;

    debugPrint('❌ WebSocket error: $error');
    _notifyConnectionStatus(false);

    if (onError != null) {
      onError!('Connection error: $error');
    }

    _attemptReconnect();
  }

  void _handleDisconnection() {
    if (_isDisposed) return;

    debugPrint('🔌 WebSocket disconnected');
    _stopPingTimer();
    _notifyConnectionStatus(false);

    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (_isDisposed || !_shouldReconnect || _isConnecting) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('❌ Max reconnection attempts reached');
      if (onError != null) {
        onError!('Connection lost. Please try refreshing.');
      }
      return;
    }

    _reconnectAttempts++;
    debugPrint(
        '🔄 Attempting reconnection #$_reconnectAttempts in ${_reconnectDelay.inSeconds}s');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isDisposed && _shouldReconnect) {
        _cleanup();
        _connectInternal();
      }
    });
  }

  /// Send a regular chat message
  void sendMessage(String message, {String? replyTo}) {
    if (_isDisposed || _channel == null) {
      debugPrint('❌ Cannot send message: not connected');
      return;
    }

    if (message.trim().isEmpty) {
      debugPrint('❌ Cannot send empty message');
      return;
    }

    try {
      final payload = {
        'type': 'message',
        'message': message.trim(),
        if (replyTo != null) 'reply_to': replyTo,
      };

      debugPrint('📤 Sending message: ${payload['message']}');
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (onError != null) {
        onError!('Failed to send message');
      }
    }
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    if (_isDisposed || _channel == null) return;

    try {
      final payload = {
        'type': 'typing',
        'is_typing': isTyping,
      };

      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('❌ Error sending typing indicator: $e');
    }
  }

  /// Send ping to keep connection alive
  void _sendPing() {
    if (_isDisposed || _channel == null) return;

    try {
      final payload = {'type': 'ping'};
      _channel!.sink.add(jsonEncode(payload));
      debugPrint('🏓 Sent ping');
    } catch (e) {
      debugPrint('❌ Error sending ping: $e');
    }
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (_) => _sendPing());
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_isDisposed) return;

    debugPrint('🔌 Disconnecting WebSocket');
    _shouldReconnect = false;
    _cleanup();
    _notifyConnectionStatus(false);
  }

  void _cleanup() {
    _stopPingTimer();
    _reconnectTimer?.cancel();

    try {
      _subscription?.cancel();
      _channel?.sink.close();
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }

    _subscription = null;
    _channel = null;
    _isConnecting = false;
  }

  void _notifyConnectionStatus(bool connected) {
    if (_isDisposed) return;

    // Use microtask to avoid calling during build
    scheduleMicrotask(() {
      if (!_isDisposed && onConnectionChanged != null) {
        onConnectionChanged!(connected);
      }
    });
  }

  /// Get connection status info
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': isConnected,
      'isConnecting': isConnecting,
      'lobbyId': _currentLobbyId,
      'userId': _currentUserId,
      'reconnectAttempts': _reconnectAttempts,
      'shouldReconnect': _shouldReconnect,
    };
  }

  /// Force reconnection
  void forceReconnect() {
    if (_isDisposed) return;

    debugPrint('🔄 Force reconnecting...');
    _reconnectAttempts = 0;
    _cleanup();

    if (_currentLobbyId != null && _currentUserId != null) {
      _connectInternal();
    }
  }

  /// Dispose and cleanup all resources
  void dispose() {
    if (_isDisposed) return;

    debugPrint('🗑️ Disposing WebSocket service');
    _isDisposed = true;
    _shouldReconnect = false;

    _cleanup();

    // Clear callbacks
    onMessageReceived = null;
    onConnectionChanged = null;
    onError = null;
    onTypingReceived = null;
  }
}
