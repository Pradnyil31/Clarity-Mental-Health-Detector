# Hugging Face Emotion Detection Setup

Your chat screen is already integrated with Hugging Face for emotion detection! Here's how to complete the setup:

## 1. Get Your Free Hugging Face API Key

1. Go to [Hugging Face](https://huggingface.co/)
2. Sign up or log in to your account
3. Navigate to **Settings** → **Access Tokens**
4. Click **"New token"**
5. Give it a name (e.g., "Clarity Mental Health App")
6. Select **"Read"** permissions (this is sufficient for inference)
7. Click **"Generate a token"**
8. Copy the generated token

## 2. Add Your API Key

1. Open `lib/services/emotion_config.dart`
2. Replace `YOUR_HUGGING_FACE_API_KEY` with your actual API key:

```dart
static const String huggingFaceApiKey = 'hf_your_actual_token_here';
```

## 3. Available Models

The app supports multiple emotion detection models:

- **distilroberta** (default): `j-hartmann/emotion-english-distilroberta-base`
  - Most accurate for general emotion detection
  - Detects: joy, sadness, anger, fear, surprise, disgust, neutral

- **roberta**: `cardiffnlp/twitter-roberta-base-emotion-multilabel-latest`
  - Better for social media style text
  - Supports multiple emotions per text

- **bert**: `nateraw/bert-base-uncased-emotion`
  - General purpose emotion detection
  - Good balance of speed and accuracy

## 4. How It Works

1. **User sends message** → Text is analyzed by Hugging Face API
2. **Emotion detected** → Results are displayed with confidence scores
3. **Fallback system** → If API fails, local keyword analysis is used
4. **Data persistence** → All messages and emotions are saved to Firestore

## 5. Features

- ✅ Real-time emotion detection
- ✅ Visual emotion indicators with colors
- ✅ Confidence scores
- ✅ Fallback to local analysis
- ✅ Data persistence
- ✅ Supportive AI responses based on detected emotions

## 6. Testing

1. Open the chat screen in your app
2. Send a message like "I'm feeling really happy today!"
3. You should see:
   - Your message
   - Bot response with supportive content
   - Emotion chip showing detected emotion (e.g., "JOY • 85%")

## 7. Troubleshooting

- **503 Error**: Model is loading, wait a few seconds and try again
- **401 Error**: Check your API key is correct
- **No emotion detected**: Fallback analysis will be used automatically
- **Rate limits**: Free tier has limits, consider upgrading for production

## 8. Cost Information

- **Free tier**: 30,000 characters/month
- **Pro tier**: $9/month for 1M characters
- **Enterprise**: Custom pricing

For a mental health app, the free tier should be sufficient for development and testing.