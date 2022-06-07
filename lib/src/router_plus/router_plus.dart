import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'response_handler/response_handler.dart';

class _RouterPlusHandler {
  final Function handler;
  final Middleware? localMiddleware;

  _RouterPlusHandler(this.handler, this.localMiddleware);

  /// Match the signature of any shelf_router handler.
  FutureOr<Response> call(
    Request request, [
    String? p1,
    String? p2,
    String? p3,
    String? p4,
    String? p5,
    String? p6,
    String? p7,
    String? p8,
    String? p9,
    String? p10,
    String? p11,
    String? p12,
    String? p13,
    String? p14,
    String? p15,
    String? p16,
  ]) async {
    if (localMiddleware != null) {
      /// Dynamically attach middleware to this request
      return Pipeline()
          .addMiddleware(localMiddleware!)
          .addHandler(_handler)
          .call(request);
    }

    return _handler.call(request);
  }

  Future<Response> _handler(Request request) async {
    var map = request.context['shelf_router/params'] as Map<String, String>;

    dynamic result;

    try {
      result = Function.apply(handler, [request, ...map.values.toList()]);
    } on NoSuchMethodError catch (_) {
      try {
        result = handler();
      } on NoSuchMethodError catch (__) {
        result = handler(request);
      }
    }

    if (result is Future) {
      result = await result;
    }

    return await resolveResponse(request, result);
  }
}

extension RouterPlusExtension on Router {
  /// Upgrades the shelf [Router] to [RouterPlus]
  RouterPlus get plus => RouterPlus(existingRouter: this);
}

/// Extended request router based on shelf [Router]
class RouterPlus {
  final Router shelfRouter;

  var _routeAdded = false;

  RouterPlus({Router? existingRouter})
      : shelfRouter = existingRouter ?? Router();

  /// Process incoming request
  Future<Response> call(Request request) async {
    var pipeline = Pipeline();

    /// Apply all global middlewares
    for (var middleware in _middlewareList) {
      pipeline = pipeline.addMiddleware(middleware);
    }

    /// Delegate to shelf_router
    return pipeline.addHandler(shelfRouter).call(request);
  }

  /// Add [handler] for [verb] requests to [route].
  ///
  /// If [verb] is `GET` the [handler] will also be called for `HEAD` requests
  /// matching [route]. This is because handling `GET` requests without handling
  /// `HEAD` is always wrong. To explicitely implement a `HEAD` handler it must
  /// be registered before the `GET` handler.
  void add(String verb, String route, Function handler,
      [Middleware? localMiddleware]) {
    shelfRouter.add(verb, route, _RouterPlusHandler(handler, localMiddleware));
    _routeAdded = true;
  }

  /// Handle all request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void all(String route, Function handler, {Middleware? use}) {
    shelfRouter.all(route, _RouterPlusHandler(handler, use));
    _routeAdded = true;
  }

  /// Mount a handler below a prefix.
  ///
  /// In this case prefix may not contain any parameters.
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void mount(String prefix, Handler handler) {
    shelfRouter.mount(prefix, handler);
  }

  /// Handle `GET` request to [route] using [handler].
  ///
  /// If no matching handler for `HEAD` requests is registered, such requests
  /// will also be routed to the [handler] registered here.
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void get(String route, Function handler, {Middleware? use}) =>
      add('GET', route, handler, use);

  /// Handle `HEAD` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void head(String route, Function handler, {Middleware? use}) =>
      add('HEAD', route, handler, use);

  /// Handle `POST` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void post(String route, Function handler, {Middleware? use}) =>
      add('POST', route, handler, use);

  /// Handle `PUT` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void put(String route, Function handler, {Middleware? use}) =>
      add('PUT', route, handler, use);

  /// Handle `DELETE` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void delete(String route, Function handler, {Middleware? use}) =>
      add('DELETE', route, handler, use);

  /// Handle `CONNECT` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void connect(String route, Function handler, {Middleware? use}) =>
      add('CONNECT', route, handler, use);

  /// Handle `OPTIONS` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void options(String route, Function handler, {Middleware? use}) =>
      add('OPTIONS', route, handler, use);

  /// Handle `TRACE` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void trace(String route, Function handler, {Middleware? use}) =>
      add('TRACE', route, handler, use);

  /// Handle `PATCH` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void patch(String route, Function handler, {Middleware? use}) =>
      add('PATCH', route, handler, use);

  /// Registers a [middleware] to use for all specified routes.
  ///
  /// You can not register a [Middleware] after you registered
  /// any route.
  void use(Middleware middleware) {
    if (_routeAdded) {
      throw ArgumentError(
          'Please use the "use()" method before adding any other routes.');
    }
    _middlewareList.add(middleware);
  }

  final _middlewareList = <Middleware>[];
}
