import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  static Future<String> translateToFrench(String text) async {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('\n', ' ');
    final response = await http.post(
      Uri.parse('https://libretranslate.de/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'q': cleaned, 'source': 'en', 'target': 'fr'}),
    );

    if (response.statusCode != 200) return text;
    final data = jsonDecode(response.body);
    return data['translatedText'] ?? text;
  }
}
