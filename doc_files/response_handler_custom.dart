// ignore_for_file: prefer_function_declarations_over_variables

import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  // #begin
  // define custom ResponseHandler
  ResponseHandler catResponseHandler = (Request request, dynamic maybeCat) =>
      maybeCat is Cat ? maybeCat.interact() : null;

  // register custom ResponseHandler as middleware
  app.use(catResponseHandler.middleware);

  app.get('/cat', () => Cat());
  // #end
  return app.call;
}

class Cat {
  String interact() => 'Purrrrr!';
}
