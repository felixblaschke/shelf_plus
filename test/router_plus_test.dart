import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:test/test.dart';

import 'test_data/person.dart';
import 'util/test_helper.dart';

void main() {
  late TestServer server;

  tearDown(() async => await server.stop());

  test('router requests', () async {
    var app = Router().plus;

    app.get('/get', () => 'get');
    app.head('/head', () => 'head');
    app.post('/post', () => 'post');
    app.put('/put', () => 'put');
    app.delete('/delete', () => 'delete');
    app.options('/options', () => 'options');
    app.patch('/patch', () => 'patch');
    app.add('get', '/add-get', () => 'add-get');
    app.all('/all', () => 'all');

    server = await runTestServer(app);

    expect(await server.fetchBody<String>('get', '/get'), 'get');
    expect(await server.fetchBody<String>('head', '/head'), '');
    expect(await server.fetchBody<String>('post', '/post'), 'post');
    expect(await server.fetchBody<String>('delete', '/delete'), 'delete');
    expect(await server.fetchBody<String>('options', '/options'), 'options');
    expect(await server.fetchBody<String>('patch', '/patch'), 'patch');
    expect(await server.fetchBody<String>('get', '/add-get'), 'add-get');
    expect(await server.fetchBody<String>('get', '/get'), 'get');
    expect(await server.fetchBody<String>('get', '/all'), 'all');
    expect(await server.fetchBody<String>('post', '/all'), 'all');
    expect(await server.fetchBody<String>('put', '/all'), 'all');
  });

  test('different method signatures', () async {
    var app = Router().plus;

    app.get('/a1', () => 'a');
    app.get('/a2', (Request request) => 'a');
    app.get('/b1/<name>', () => 'b');
    app.get('/b2/<name>', (Request request) => 'b');
    app.get('/b3/<name>', (Request request, String name) => 'b:$name');

    server = await runTestServer(app);

    expect(await server.fetchBody<String>('get', '/a1'), 'a');
    expect(await server.fetchBody<String>('get', '/a2'), 'a');
    expect(await server.fetchBody<String>('get', '/b1/john'), 'b');
    expect(await server.fetchBody<String>('get', '/b2/john'), 'b');
    expect(await server.fetchBody<String>('get', '/b3/john'), 'b:john');
  });

  test('json handler', () async {
    var persons = [
      Person(firstName: 'John', lastName: 'Doe'),
      Person(firstName: 'Jane', lastName: 'Doe')
    ];

    var app = Router().plus;

    app.get('/object', () => {'name': 'john', 'age': 42});
    app.get('/list', () => [1, 2, 3]);
    app.get('/emptylist', () => []);
    app.get('/iterable', () => [1, 2, 3, 4, 5].where((n) => n > 2));
    app.get('/persons', () => persons);
    app.get('/persons/john', () => persons.where((p) => p.firstName == 'John'));

    server = await runTestServer(app);

    var r1 = await server.fetch('get', '/object');
    expect(r1.headers['content-type']?.first, 'application/json');
    expect(r1.data, {'name': 'john', 'age': 42});

    var r2 = await server.fetch('get', '/list');
    expect(r2.headers['content-type']?.first, 'application/json');
    expect(r2.data, [1, 2, 3]);

    var r3 = await server.fetch('get', '/iterable');
    expect(r3.headers['content-type']?.first, 'application/json');
    expect(r3.data, [3, 4, 5]);

    var r4 = await server.fetch('get', '/persons');
    expect(r4.headers['content-type']?.first, 'application/json');
    expect(r4.data[0]['firstName'], 'John');
    expect(r4.data[1]['firstName'], 'Jane');

    var r5 = await server.fetch('get', '/persons/john');
    expect(r5.headers['content-type']?.first, 'application/json');
    expect(r5.data[0]['firstName'], 'John');
    expect(r5.data[0]['lastName'], 'Doe');

    var r6 = await server.fetch('get', '/emptylist');
    expect(r6.headers['content-type']?.first, 'application/json');
    expect(r6.data, []);
  });

  test('register response handler', () async {
    var app = Router().plus;

    app.get('/cat', () => Cat());

    server = await runTestServer(Pipeline()
        .addMiddleware(addResponseHandler([catHandler]))
        .addHandler(app));

    expect(await server.fetchBody<String>('get', '/cat'), 'Purrr!');
  });

  test('register response handler via extension', () async {
    var app = Router().plus;

    app.get('/cat', () => Cat(), use: catHandler.middleware);

    server = await runTestServer(app);
    expect(await server.fetchBody<String>('get', '/cat'), 'Purrr!');
  });

  test('middleware usage', () async {
    var app = Router().plus;

    app.use(wrapBody('a'));

    app.get('/number', () => '1', use: wrapBody('b') + wrapBody('c'));

    server = await runTestServer(app);

    expect(await server.fetchBody<String>('get', '/number'), 'a(b(c(1)))');
  });

  test('middleware without routes', () async {
    var app = Router().plus;

    Middleware returnHello() =>
        (Handler _) => (Request request) async => Response.ok('hello');

    app.use(returnHello());

    server = await runTestServer(app);

    expect(await server.fetchBody<String>('get', '/'), 'hello');
    expect(await server.fetchBody<String>('post', '/dynamic_route'), 'hello');
    expect(
        await server.fetchBody<String>('options', '/dynamic_route'), 'hello');
  });

  test('toJsonHandler', () async {
    var app = Router().plus;

    app.get('/person', () => Person(firstName: 'John', lastName: 'Doe'));

    server = await runTestServer(app);

    var r1 = await server.fetch('get', '/person');
    expect(r1.headers['content-type']?.first, 'application/json');
    expect(r1.data, {'firstName': 'John', 'lastName': 'Doe'});
  });

  test('fileHandler', () async {
    var app = Router().plus;

    app.get('/bird', () => File('test/test_data/bird.jpg'));

    app.get('/virtual/path/<path|.*>', (Request request, String path) {
      return File('test/test_data/$path');
    });

    server = await runTestServer(app);

    var r1 = await server.fetch('get', '/bird');
    expect(r1.headers[HttpHeaders.contentTypeHeader]?.first, 'image/jpeg');
    expect(r1.headers[HttpHeaders.contentLengthHeader]?.first, '15680');

    var r2 = await server.fetch('get', '/virtual/path/bird.jpg');
    expect(r2.headers[HttpHeaders.contentTypeHeader]?.first, 'image/jpeg');
    expect(r2.headers[HttpHeaders.contentLengthHeader]?.first, '15680');

    var r3 = await server.fetch('get', '/virtual/path/example.html');
    expect(r3.headers[HttpHeaders.contentTypeHeader]?.first, 'text/html');
    expect((r3.data as String).contains('<h1>Example</h1>'), true);
  });

  test('download test', () async {
    var app = Router().plus;

    app.get('/image', () => File('test/test_data/bird.jpg'),
        use: download(filename: 'bird.jpg'));

    server = await runTestServer(app);

    var r = await server.fetch('get', '/image');
    expect(r.headers['content-disposition']?.first,
        'attachment; filename=bird.jpg');
  });

  test('compose Middleware and ResponseHandler', () async {
    var app = Router().plus;

    app.get('/data', () => wrapBody('a') >> 'b');

    server = await runTestServer(app);

    var r = await server.fetch('get', '/data');
    expect(r.data, 'a(b)');
  });

  test('content type middleware', () async {
    var app = Router().plus;

    app.get('/html1', () => '<h1>Headline</h1>',
        use: setContentType('text/html'));

    app.get('/html2', () => '<h1>Headline</h1>', use: typeByExtension('html'));

    server = await runTestServer(app);

    var r1 = await server.fetch('get', '/html1');
    expect(r1.headers[HttpHeaders.contentTypeHeader]?.first, 'text/html');

    var r2 = await server.fetch('get', '/html2');
    expect(r2.headers[HttpHeaders.contentTypeHeader]?.first, 'text/html');
  });

  test('cascade helper', () async {
    var app1 = Router().plus;
    var app2 = Router().plus;

    app1.get('/a', () => Response.notFound(''));
    app2.get('/a', () => 'ok');

    server = await runTestServer(cascade([app1, app2]));

    var r = await server.fetch('get', '/a');
    expect(r.data, 'ok');
  });

  test('routeParameter extension', () async {
    var app = Router().plus;

    app.get('/<action>/<name>', (Request request) {
      return 'Hi ${request.routeParameter('name')}, I like ${request.routeParameter('action')}';
    });

    server = await runTestServer(app);

    var r = await server.fetch('get', '/sports/john');
    expect(r.data, 'Hi john, I like sports');
  });

  test('router mount', () async {
    var app = Router().plus;
    var subapp = Router().plus;

    app.mount('/prefix/', subapp);
    subapp.get('/data', () => 'ok');

    server = await runTestServer(app);

    var r = await server.fetch('get', '/prefix/data');
    expect(r.data, 'ok');
  });

  test('binary handler', () async {
    var app = Router().plus;

    app.get('/bird1', () => File('test/test_data/bird.jpg').readAsBytesSync());
    app.get('/bird2', () => File('test/test_data/bird.jpg').openRead());

    server = await runTestServer(app);

    var r1 = await server.fetch('get', '/bird1');
    expect(r1.headers[HttpHeaders.contentTypeHeader]?.first,
        'application/octet-stream');
    expect(r1.data.length, 14897);

    var r2 = await server.fetch('get', '/bird2');
    expect(r2.headers[HttpHeaders.contentTypeHeader]?.first,
        'application/octet-stream');
    expect(r2.data.length, 14897);
  });

  test('websocket handler', () async {
    var app = Router().plus;

    app.get('/ws', () {
      return WebSocketSession(
          onOpen: (session) => session.send('open'),
          onMessage: (session, data) {
            session.send("message: $data");
            session.close();
          });
    });

    server = await runTestServer(app);

    final channel = WebSocketChannel.connect(
      Uri.parse('${server.websocketHost}/ws'),
    );

    var receivedData = [];

    Future.delayed(Duration(milliseconds: 100))
        .then((_) => channel.sink.add('websocket'));

    await for (final data in channel.stream) {
      receivedData.add(data);
    }

    expect(receivedData, ['open', 'message: websocket']);
  });
}

class Cat {
  String act() => 'Purrr!';
}

Middleware wrapBody(String identifier) =>
    (Handler innerHandler) => (Request request) async {
          var response = await innerHandler(request);
          return response.change(
              body: '$identifier(${await response.readAsString()})');
        };

ResponseHandler get catHandler => (Request request, dynamic cat) {
      if (cat is Cat) {
        return cat.act();
      }
      return null;
    };
