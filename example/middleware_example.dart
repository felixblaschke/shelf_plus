import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  Handler greeterMiddleware(innerHandler) {
    return (request) async {
      final innerResponse = await innerHandler(request);
      return innerResponse.change(
          body: 'Hello ${await innerResponse.readAsString()}');
    };
  }

  app.get('/', () => 'world', use: greeterMiddleware);

  return app;
}
