import 'package:shelf_plus/shelf_plus.dart';

///example without custom environment variables
void main() => shelfRun(init, {});

Handler init() {
  return (Request request) => Response.ok('Hello!');
}
