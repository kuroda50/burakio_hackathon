import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  // final DotEnv env = DotEnv()..load(); // DotEnv インスタンスを作成してロード
  Future<String> sendMessage(String userMessage) async {
    // 環境変数の読み込み
    final String? _apiKey = Platform.environment['OPENAI_API_KEY']; // OpenAIのAPIキー
    if (_apiKey == null) {
      throw Exception("APIキーが設定されていません");
    }
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4', // GPTのバージョン（'gpt-3.5-turbo' も可）
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String,dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final String message = data['choices'][0]['message']['content'] as String;
      return message.trim(); // AIの返答
    } else {
      throw Exception('Failed to fetch response from OpenAI: ${response.body}');
    }
  }
}
