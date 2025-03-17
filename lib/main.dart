import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'summary.dart';

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHome());
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('OpenAI API Test')),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Summary()),
                  );
                },
                child: Text("要約画面に移動する")),
            Center(child: OpenAIChat()),
          ],
        ));
  }
}

class OpenAIChat extends StatefulWidget {
  @override
  _OpenAIChatState createState() => _OpenAIChatState();
}

class _OpenAIChatState extends State<OpenAIChat> {
  String _response = 'Loading...';

  @override
  void initState() {
    super.initState();
    _testOpenAI();
  }

  // OpenAI APIにリクエストを送る関数
  Future<void> _testOpenAI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = json.encode({
      'model': 'gpt-4', // または 'gpt-3.5-turbo'
      'messages': [
        {'role': 'user', 'content': 'Hello, OpenAI!'}
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _response = data['choices'][0]['message']['content'];
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_response);
  }
}
