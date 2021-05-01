import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

Handler init() {
  //@start
  var app = Router().plus;
  //@end
  return app;
}
