import 'package:dart_frog/dart_frog.dart';

Response _handleOptions(RequestContext context) => Response(
      statusCode: 204,
      headers: _corsHeaders,
    );

final _corsHeaders = {
  'Access-Control-Allow-Origin': '*', // すべてのオリジンを許可（セキュリティ上は本番環境で制限すべき）
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// ミドルウェア関数
Middleware corsMiddleware() {
  return (Handler handler) {
    return (RequestContext context) async {
      if (context.request.method == HttpMethod.options) {
        return _handleOptions(context);  // OPTIONS メソッドの場合、適切なレスポンスを返す
      }
      final response = await handler(context);  // 他のリクエストは処理する
      return response.copyWith(headers: {...response.headers, ..._corsHeaders});
    };
  };
}