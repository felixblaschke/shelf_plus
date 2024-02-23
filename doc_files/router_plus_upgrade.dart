import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  // #begin
  var app = Router().plus;
  // #end
  return app.call;
}
