/// Gemini REST API endpoint constants.
///
/// HOW TO GET YOUR API KEY:
/// 1. Go to https://aistudio.google.com/apikey
/// 2. Click "Create API key"
/// 3. Copy the key (starts with "AIza...")
/// 4. Store it in your .env file as: GEMINI_API_KEY=AIza...
///
/// HOW THE ENDPOINT WORKS:
/// Base URL  : https://generativelanguage.googleapis.com/v1beta/models/
/// Model name: gemini-2.0-flash   (fast, supports text + vision, free tier)
/// Action    : :generateContent   (single-turn, non-streaming)
/// Full URL  : BASE + MODEL + ACTION + ?key=YOUR_API_KEY
///
/// The key is appended as a query parameter — NOT in headers.
/// This is different from most REST APIs that use Bearer tokens.
class GeminiEndpoints {
  GeminiEndpoints._();

  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models/';

  /// gemini-2.0-flash: supports text + image input, fast, generous free quota.
  /// Use this for your medical chatbot.
  static const String generateContent =
      '${_base}gemini-2.0-flash:generateContent';

  /// Helper: appends the API key as a query parameter.
  /// Usage: GeminiEndpoints.withKey(apiKey)
  static String withKey(String apiKey) => '$generateContent?key=$apiKey';
}