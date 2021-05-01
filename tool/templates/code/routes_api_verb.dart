import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/path/to/match', () => 'a response');
  //@end
  return app;
}
