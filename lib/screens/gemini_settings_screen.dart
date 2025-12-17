import 'package:flutter/material.dart';
import '../services/gemini_config.dart';

class GeminiSettingsScreen extends StatefulWidget {
  const GeminiSettingsScreen({super.key});

  @override
  State<GeminiSettingsScreen> createState() => _GeminiSettingsScreenState();
}

class _GeminiSettingsScreenState extends State<GeminiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _hasApiKey = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    setState(() => _isLoading = true);

    try {
      final hasKey = await GeminiConfig.hasApiKey();
      final apiKey = await GeminiConfig.getApiKey();

      setState(() {
        _hasApiKey = hasKey;
        if (hasKey && apiKey != null) {
          _apiKeyController.text = apiKey;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading API key: $e')));
      }
    }
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid API key')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GeminiConfig.setApiKey(apiKey);
      setState(() {
        _hasApiKey = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving API key: $e')));
      }
    }
  }

  Future<void> _clearApiKey() async {
    setState(() => _isLoading = true);

    try {
      await GeminiConfig.clearApiKey();
      setState(() {
        _hasApiKey = false;
        _apiKeyController.clear();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('API key cleared')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing API key: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _hasApiKey ? Icons.check_circle : Icons.warning,
                                color: _hasApiKey
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gemini API Configuration',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasApiKey
                                ? 'Gemini AI is configured and ready to use.'
                                : 'Please configure your Gemini API key to use AI chat features.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('API Key', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      hintText: 'Enter your Gemini API key',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveApiKey,
                          child: const Text('Save API Key'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_hasApiKey)
                        ElevatedButton(
                          onPressed: _clearApiKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 8),
                              Text(
                                'How to get your API key',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Go to Google AI Studio (aistudio.google.com)\n'
                            '2. Sign in with your Google account\n'
                            '3. Click "Get API key" in the left sidebar\n'
                            '4. Create a new API key\n'
                            '5. Copy and paste it above',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
