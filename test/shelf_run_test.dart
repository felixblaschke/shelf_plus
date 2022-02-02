// ignore_for_file: prefer_function_declarations_over_variables

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
    fail('implement me');
  });
}
