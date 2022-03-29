import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  app.use(corsHeaders()); // use CORS middleware

  app.get('/', () => {'data': 'This API is CORS enabled.'});

  return app;
}
