import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  // #begin
  app.get('/one', () => setContentType('application/json') >> '1');

  app.get('/two', () => '2', use: setContentType('application/json'));
  // #end
  return app.call;
}
