import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

late Middleware middlewareA;
late Middleware middlewareB;
late Middleware middlewareC;

Handler init() {
  // #begin
  var app = Router().plus;

  app.use(middlewareA); // apply to all routes

  // apply to a single route
  app.get('/request1', () => 'response', use: middlewareB);

  // combine middleware with + operator
  app.get('/request2', () => 'response', use: middlewareB + middlewareC);
  // #end
  return app.call;
}
