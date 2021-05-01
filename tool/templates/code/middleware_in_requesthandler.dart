import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

late dynamic middleware;

Handler init() {
  var app = Router().plus;

  //@start
  app.get('/request/<value>', (Request request, String value) {
    return middleware(value) >> 'response';
  });
  //@end
  return app;
}
