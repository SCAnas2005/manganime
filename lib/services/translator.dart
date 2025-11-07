import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service de traduction de texte.
///
/// Cette classe fournit une méthode statique pour traduire
/// un texte de l'anglais vers le français en utilisant
/// l'API LibreTranslate.
class Translator {
  /// Traduit un texte anglais en français.
  ///
  /// - [text] : le texte à traduire.
  /// - Retourne une `Future<String>` contenant le texte traduit.
  ///
  /// Le texte est pré-nettoyé pour enlever les balises HTML et les retours à la ligne
  /// avant d'être envoyé à l'API.
  /// Si la traduction échoue (code HTTP != 200), le texte original est renvoyé.
  static Future<String> translateToFrench(String text) async {
    // Nettoyage du texte pour retirer les balises HTML et les sauts de ligne
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('\n', ' ');

    // Requête POST vers l'API LibreTranslate
    final response = await http.post(
      Uri.parse('https://libretranslate.de/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'q': cleaned, 'source': 'en', 'target': 'fr'}),
    );

    // Si la traduction échoue, on renvoie le texte original
    if (response.statusCode != 200) return text;

    // Lecture de la réponse JSON
    final data = jsonDecode(response.body);

    // Retourne le texte traduit ou le texte original si absent
    return data['translatedText'] ?? text;
  }
}
