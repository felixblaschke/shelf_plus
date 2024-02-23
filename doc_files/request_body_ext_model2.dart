import 'package:shelf_plus/shelf_plus.dart';

import 'other_code.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;
  // #begin
  app.post('/person', (Request request) async {
    var person = await request.body.asPerson;
    return 'You send me: ${person.name}';
  });
  // #end
  return app.call;
}

extension PersonAccessor on RequestBodyAccessor {
  Future<Person> get asPerson async => Person.fromJson(await asJson);
}
