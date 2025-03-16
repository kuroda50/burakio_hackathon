import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  group('POST /chat', () {
    test('responds with 405 for GET request.', () async {
      // モックを作成
      final context = _MockRequestContext();
      final request = _MockRequest();

      // GETリクエストとして設定
      when(() => request.method).thenReturn(HttpMethod.get);
      when(() => context.request).thenReturn(request);

      // onRequestを実行
      final response = await route.onRequest(context);

      // ステータスコードが 405 であることを確認
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
      expect(response.body(), completion(equals('Method Not Allowed')));
    });
  });
}
