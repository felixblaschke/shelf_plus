import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  //@start
  // define custom ResponseHandler
  ResponseHandler catResponseHandler = (Request request, dynamic maybeCat) =>
      maybeCat is Cat ? maybeCat.interact() : null;

  // register custom ResponseHandler as middleware
  app.use(catResponseHandler.middleware);

  app.get('/cat', () => Cat());
  //@end
  return app;
}

class Cat {
  String interact() => 'Purrrrr!';
}
