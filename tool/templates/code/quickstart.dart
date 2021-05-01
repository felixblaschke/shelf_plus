import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

Handler init() {
  var app = Router().plus;

  app.get('/', () => 'Hello World!');

  return app;
}
