/// Thrown when an AI chat API call fails.
///
/// Contains a human-readable [message] and an optional HTTP [statusCode]
/// so the repository layer can decide whether to fall back to the next provider.
class MedicalApiException implements Exception {
  final String message;
  final int? statusCode;

  const MedicalApiException(this.message, {this.statusCode});

  /// Whether this error indicates rate-limiting / quota exhaustion,
  /// meaning the fallback provider should be attempted.
  bool get isRateLimited => statusCode == 429;

  /// Whether the status code is retryable (429, 500, 502, 503).
  bool get isRetryable =>
      statusCode == 429 ||
      statusCode == 500 ||
      statusCode == 502 ||
      statusCode == 503;

  @override
  String toString() => message;
}
