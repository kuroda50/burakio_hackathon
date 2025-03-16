import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'middleware/cors.dart'; // CORS ミドルウェアをインポート

Future<void> main() async {
  final handler = Pipeline()
      .addMiddleware(corsMiddleware())  // ミドルウェアを追加
      .addHandler((context) async {
        return Response.json(body: {'message': 'Dart Frog API is running!'});
      });

  await serve(handler, InternetAddress.anyIPv4, 8080);  // サーバーを起動
}
