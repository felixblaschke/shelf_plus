import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<TestServer> runTestServer(Handler handler) async {
  var server = TestServer(handler);
  await server.start();
  return server;
}

class TestServer {
  HttpServer? server;
  Handler handler;

  TestServer(this.handler);

  Future<void> start() async {
    server = await io.serve(handler, 'localhost', 0);
  }

  Future<void> stop() async {
    await server?.close(force: true);
  }

  String get host {
    return 'http://localhost:${server?.port}';
  }

  String get websocketHost {
    return 'ws://localhost:${server?.port}';
  }

  Future<dio.Response<T>> fetch<T>(String method, String path) async {
    return await dio.Dio().request<T>('$host$path',
        options: dio.Options(method: method.toUpperCase()));
  }

  Future<T> fetchBody<T>(String method, String path) async {
    var response = await fetch<T>(method, path);
    return response.data!;
  }
}
