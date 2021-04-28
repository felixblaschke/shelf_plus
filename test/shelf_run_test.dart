import 'package:dio/dio.dart' as dio;
import 'package:shelf_plus/shelf_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('shelf run', () async {
    var init = () => (Request request) => Response.ok('ok');

    var ctx = await shelfRun(init);

    var response = await dio.Dio().get('http://localhost:8080/');
    expect(response.data!, 'ok');

    await ctx.close();
  });
}
