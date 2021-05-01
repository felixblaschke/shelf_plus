import 'dart:io';
import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';
import 'other_code.dart';

void main() => shelfRun(init, envExample);

late dynamic middleware;

Handler init() {
  //@start
  var app = Router().plus;

  app.use(middleware());

  app.get('/text', () => 'I am a text');

  app.get(
      '/html/<name>', (Request request, String name) => '<h1>Hello $name</h1>',
      use: typeByExtension('html'));

  app.get('/file', () => File('path/to/file.zip'));

  app.get('/person', () => Person(name: 'John', age: 42));
  //@end
  return app;
}
