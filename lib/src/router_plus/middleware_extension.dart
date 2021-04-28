import 'package:shelf/shelf.dart';

import 'response_handler/response_handler.dart';

extension MiddlewareExtension on Middleware {
  /// Combines two middlewares to a single one
  Middleware operator +(Middleware middleware) =>
      Pipeline().addMiddleware(this).addMiddleware(middleware).middleware;

  /// Combines this middleware with [data] that gets processed by the
  /// [ResponseHandler] mechanism.
  dynamic operator >>(dynamic data) {
    return Pipeline()
        .addMiddleware(this)
        .addHandler((request) async => await resolveResponse(request, data));
  }
}
