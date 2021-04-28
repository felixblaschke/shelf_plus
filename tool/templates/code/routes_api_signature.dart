import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/minimalistic', () => 'response');

  app.get('/with/request', (Request request) => 'response');

  app.get('/clients/<id>', (Request request, String id) => 'response: $id');

  app.get('/customer/<id>', (Request request) {
    // alternative access to route parameters
    return 'response: ${request.routeParameter('id')}';
  });
  //@end
  return app;
}
