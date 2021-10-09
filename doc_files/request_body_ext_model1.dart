import 'package:shelf_plus/shelf_plus.dart';

import 'other_code.dart';

// #begin
extension PersonAccessor on RequestBodyAccessor {
  Future<Person> get asPerson async => Person.fromJson(await asJson);
}
// #end
