import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  // #begin
  app.get('/', () => '<h1>Hi!</h1>', use: typeByExtension('html'));
  // #end
  return app.call;
}
