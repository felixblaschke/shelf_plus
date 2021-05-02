import 'package:shelf_plus/shelf_plus.dart';

//@start
void main() => shelfRun(init, defaultBindPort: 3000);
//@end

Handler init() {
  return (Request request) => Response.ok('Hello!');
}
