import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

late dynamic middleware;

Handler init() {
  var app = Router().plus;

  // #begin
  app.get('/request/<value>', (Request request, String value) {
    return middleware(value) >> 'response';
  });
  // #end
  return app;
}
