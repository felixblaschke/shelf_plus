import 'package:shelf_plus/shelf_plus.dart';

import 'other_code.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  //@start
  app.post('/text', (Request request) async {
    var text = await request.body.asString;
    return 'You send me: $text';
  });

  app.post('/json', (Request request) async {
    var person = Person.fromJson(await request.body.asJson);
    return 'You send me: ${person.name}';
  });
  //@end
  return app;
}
