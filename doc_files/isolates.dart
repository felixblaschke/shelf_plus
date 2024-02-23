import 'dart:isolate';
import 'package:shelf_plus/shelf_plus.dart';

void main() {
  const numberOfIsolates = 8;

  for (var i = 0; i < numberOfIsolates - 1; i++) {
    Isolate.spawn(spawnServer, null, debugName: i.toString()); // isolate 0..7
  }
  spawnServer(null); // use main isolate as the 8th isolate
}

void spawnServer(_) => shelfRun(init, defaultShared: true);

Handler init() {
  var app = Router().plus;

  app.get('/', () async {
    await Future.delayed(Duration(milliseconds: 500)); // simulate load
    return 'Hello from isolate: ${Isolate.current.debugName}';
  });

  return app.call;
}
