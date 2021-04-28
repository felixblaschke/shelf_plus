import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/path/to/match', () => 'a response');
  //@end
  return app;
}
