import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('OpenAI API Test')),
        body: Center(child: OpenAIChat()),
      ),
    );
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
    firstFunc();
  }

  Future<void> firstFunc() async {
    var response = await sendMessageToAI("こんにちはと言ってください");
    setState(() {
      _response = response;
    });
  }

  Future<String> sendMessageToAI(String message) async {
    final url = Uri.parse('http://localhost:63097/index');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response']; // OpenAIの返答を取得
    } else {
      throw Exception('Failed to get response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_response);
  }
}
