import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final router = Router().plus;

  router.get('/', () => {'data': 'This API is CORS enabled.'});

  return corsHeaders() >> router;
}
