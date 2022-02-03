// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:isolate';

import 'package:dio/dio.dart' as dio;
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

void main() {
  test('shelf run', () async {
    var init = () => (Request request) => Response.ok('ok');

    var ctx = await shelfRun(init);

    var response = await dio.Dio().get('http://localhost:8080/');
    expect(response.data!, 'ok');

    await ctx.close();
  });

  test('shelf run - other default port', () async {
    var init = () => (Request request) => Response.ok('ok');

    var ctx = await shelfRun(init, defaultBindPort: 8099);

    var response = await dio.Dio().get('http://localhost:8099/');
    expect(response.data!, 'ok');

    await ctx.close();
  });

  test('shelf run - isolates / shared', () async {
    var ctxList = <ShelfRunContext>[];

    for (var i = 0; i < 10; i++) {
      var rp = ReceivePort();
      await Isolate.spawn<SendPort>(
        _isolateSpawnServer,
        rp.sendPort,
        debugName: "$i",
      );
      ctxList.add(await rp.first);
    }

    var responses = <String>{};
    while (responses.length < 10) {
      responses.add((await dio.Dio().get('http://localhost:8100/')).data);
    }

    expect(responses.length, 10);

    for (var ctx in ctxList) {
      await ctx.close();
    }
  });
}

Handler isolateInit() =>
    (Request request) => Response.ok(Isolate.current.debugName);

void _isolateSpawnServer(sendPort) async {
  sendPort.send(await shelfRun(
    isolateInit,
    defaultBindPort: 8100,
    defaultShared: true,
  ));
}
