import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

Handler init() {
  var app1 = Router().plus;
  var app2 = Router().plus;

  app1.get('/maybe', () => Response.notFound('no idea'));

  app2.get('/maybe', () => 'got it!');

  return cascade([app1, app2]);
}
