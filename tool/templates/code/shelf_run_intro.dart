import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  return (Request request) => Response.ok('Hello!');
}
