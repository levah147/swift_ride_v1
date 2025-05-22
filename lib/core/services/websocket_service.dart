import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool _isConnected = false;
  
  Future<void> connect(String userId) async {
    if (_isConnected) return;
    
    final token = await _secureStorage.read(key: 'access_token');
    final baseUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
    
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseUrl/ws/user/$userId/?token=$token'),
      );
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _messageController.add(data);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
        },
      );
      
      _isConnected = true;
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _isConnected = false;
    }
  }
  
  void send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
  
  void dispose() {
    disconnect();
    _messageController.close();
  }
}