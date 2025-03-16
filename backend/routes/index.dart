import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../services/openai_service.dart'; // OpenAIとやり取りするサービス

Future<Response> onRequest(RequestContext context) async {
  print("呼ばれたよ");
  if (context.request.method == HttpMethod.post) {
    // Flutterから送られてきたリクエストのボディを取得
    final body = await context.request.body();
    final data = jsonDecode(body);
    final String userMessage = data['message'] as String; // ユーザーのメッセージを取得

    // OpenAI APIを呼び出してレスポンスを取得
    final openAiResponse = await OpenAIService().sendMessage(userMessage);

    // FlutterにOpenAIの応答を返す
    return Response.json(body: {'response': openAiResponse});
  }

  return Response(statusCode: 405, body: 'Method Not Allowed'); // POST以外を禁止
}
