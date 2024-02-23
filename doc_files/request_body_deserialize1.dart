import 'package:shelf_plus/shelf_plus.dart';

import 'other_code.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  app.post('/json', (Request request) async {
    // #begin
    var person = await request.body.as(Person.fromJson);
    // #end
    return 'You send me: ${person.name}';
  });

  return app.call;
}
