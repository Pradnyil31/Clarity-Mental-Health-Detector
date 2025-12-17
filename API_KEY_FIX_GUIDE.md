# 🔧 API Key Permission Fix Guide

## ❌ Problem Identified

Your current Hugging Face API key has **insufficient permissions** to access the Inference API.

**Error message:** `"This authentication method does not have sufficient permissions to call Inference Providers"`

## ✅ Solution: Create a New API Key

### Step 1: Delete Current Token
1. Go to [Hugging Face Settings > Access Tokens](https://huggingface.co/settings/tokens)
2. Find your current token: `REDACTED`
3. Click **"Delete"** to remove it

### Step 2: Create New Token with Proper Permissions
1. Click **"New token"**
2. **Name:** `Clarity Mental Health App`
3. **Type:** Select **"Read"** (this is crucial!)
4. **Repositories:** Leave empty or select "All"
5. Click **"Generate a token"**
6. **Copy the new token** (starts with `hf_`)

### Step 3: Update Your App
1. Open `lib/services/emotion_config.dart`
2. Replace the old API key with your new one:

```dart
static const String huggingFaceApiKey = 'hf_YOUR_NEW_TOKEN_HERE';
```

## 🧪 Test the Fix

### Method 1: Check Debug Console
When you send a message in chat, you should see:
```
Has valid API key: true
Using API key for request
Hugging Face API Response: 200
Response data: [[{label: joy, score: 0.8234}, ...]]
```

Instead of:
```
❌ API KEY PERMISSION ERROR: Your Hugging Face token needs proper permissions!
🔄 Using fallback local emotion analysis (API not available)
```

### Method 2: Look for Confidence Levels
Bot responses should include confidence percentages:
- ✅ **Working:** "I can clearly sense joy (85% confidence)!"
- ❌ **Not working:** Generic responses without percentages

### Method 3: Check App Bar
- ✅ **Working:** "AI-powered emotion detection active"
- ❌ **Not working:** "Using local emotion analysis"

## 🔍 Common Issues

### "Token not found" or "Invalid token"
- Make sure you copied the complete token
- Token should start with `hf_`
- Don't include any extra spaces

### Still getting permission errors
- Make sure you selected **"Read"** permissions when creating the token
- Try creating a completely new token
- Wait a few minutes after creating the token

### 503 Service Unavailable
- This is normal - the model is loading
- Wait 30-60 seconds and try again
- Free tier models sometimes take time to "wake up"

## 💡 Why This Happened

Hugging Face has different token types:
- **Fine-grained tokens:** Limited to specific repositories
- **Classic tokens:** Can access inference API with proper permissions

Your original token was likely created with limited scope or wrong permissions.

## 🎯 Expected Results After Fix

1. **Debug console shows API calls working**
2. **Bot responses include confidence percentages**
3. **Different emotional messages get more nuanced responses**
4. **App bar shows "AI-powered emotion detection active"**

Once you create the new token with proper permissions, the Hugging Face API should work perfectly!