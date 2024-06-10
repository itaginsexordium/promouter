// lib/services/telegram_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelegramService {
  final String botToken = '7470158217:AAHQLw0mmNzQY4i0AmS4-gM1RDT8alncvng';
  final String chatId = '-1002186568772';

  Future<void> sendOrder(String message) async {
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'chat_id': chatId, 'text': message}),
    );

    if (response.statusCode != 200) {
      SnackBar(content: Text(response.statusCode.toString() + "\n" ));
      throw Exception('Failed to send message');
    }
  }
}
