import 'package:dio/dio.dart' as dio;
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

import 'util/test_helper.dart';

void main() {
  late TestServer server;

  tearDown(() async => await server.stop());

  test('body string', () async {
    var app = Router().plus;
    String? body;

    app.post('/route', (Request request) async {
      body = await request.body.asString;
      return 'ok';
    });

    server = await runTestServer(app);

    await dio.Dio().post('${server.host}/route', data: 'hello');

    expect(body, 'hello');
  });

  test('body binary', () async {
    var app = Router().plus;
    var body = <int>[];

    app.post('/route', (Request request) async {
      var stream = request.body.asBinary;
      await for (var list in stream) {
        body.addAll(list);
      }
      return 'ok';
    });

    server = await runTestServer(app);

    await dio.Dio().post('${server.host}/route', data: 'hello');

    expect(body, [104, 101, 108, 108, 111]);
  });

  test('body json', () async {
    var app = Router().plus;
    Map<String, dynamic>? body;

    app.post('/route', (Request request) async {
      body = await request.body.asJson;
      return 'ok';
    });

    server = await runTestServer(app);

    await dio.Dio().post('${server.host}/route', data: {'a': '1', 'b': 2});

    expect(body!['a'], '1');
    expect(body!['b'], 2);
  });

  test('body object deserialization', () async {
    var app = Router().plus;
    Person? body;

    app.post('/route', (Request request) async {
      body = await request.body.as(Person.fromJson);
      return 'ok';
    });

    server = await runTestServer(app);

    await dio.Dio().post('${server.host}/route',
        data: Person(name: 'john', age: 42).toJson());

    expect(body!.name, 'john');
    expect(body!.age, 42);
  });
}

class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }

  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: json['name'], age: json['age']);
  }
}
