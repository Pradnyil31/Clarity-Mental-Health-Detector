class EmotionConfig {
  // IMPORTANT: Your current API key has insufficient permissions!
  // You need to create a new token with proper permissions:
  //
  // 1. Go to https://huggingface.co/settings/tokens
  // 2. Delete your current token (REDACTED)
  // 3. Create a NEW token with these settings:
  //    - Name: "Clarity Mental Health App"
  //    - Type: "Read"
  //    - Repositories: "All" (or leave empty for all)
  // 4. Replace the value below with your NEW API key

  static const String huggingFaceApiKey = '';

  // Available models - you can switch between these
  static const String defaultModel =
      'goemotions'; // 28 detailed emotions (RECOMMENDED)
  // Alternative models:
  // - 'distilroberta': 7 basic emotions
  // - 'roberta': Better for social media text
  // - 'bert': General purpose emotion detection

  static bool get hasValidApiKey =>
      huggingFaceApiKey.isNotEmpty &&
      huggingFaceApiKey != 'YOUR_HUGGING_FACE_API_KEY';
}
