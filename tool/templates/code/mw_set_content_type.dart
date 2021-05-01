import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/one', () => setContentType('application/json') >> '1');

  app.get('/two', () => '2', use: setContentType('application/json'));
  //@end
  return app;
}
