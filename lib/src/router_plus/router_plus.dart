import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'response_handler/response_handler.dart';

class _RouterPlusHandler {
  final Function handler;
  final List<Middleware> middlewares;

  _RouterPlusHandler(this.handler, this.middlewares);

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
    var pipeline = Pipeline();

    for (var middleware in middlewares) {
      pipeline = pipeline.addMiddleware(middleware);
    }

    return pipeline.addHandler(_handler).call(request);
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

  Future<Response> call(Request request) => shelfRouter.call(request);

  /// Add [handler] for [verb] requests to [route].
  ///
  /// If [verb] is `GET` the [handler] will also be called for `HEAD` requests
  /// matching [route]. This is because handling `GET` requests without handling
  /// `HEAD` is always wrong. To explicitely implement a `HEAD` handler it must
  /// be registered before the `GET` handler.
  void add(String verb, String route, Function handler,
      [List<Middleware>? middlewares]) {
    middlewares ??= <Middleware>[];
    shelfRouter.add(verb, route, _RouterPlusHandler(handler, middlewares));
    _routeAdded = true;
  }

  /// Handle all request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void all(String route, Function handler, {Middleware? use}) {
    shelfRouter.all(route, _RouterPlusHandler(handler, _middlewareList(use)));
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
      add('GET', route, handler, _middlewareList(use));

  /// Handle `HEAD` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void head(String route, Function handler, {Middleware? use}) =>
      add('HEAD', route, handler, _middlewareList(use));

  /// Handle `POST` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void post(String route, Function handler, {Middleware? use}) =>
      add('POST', route, handler, _middlewareList(use));

  /// Handle `PUT` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void put(String route, Function handler, {Middleware? use}) =>
      add('PUT', route, handler, _middlewareList(use));

  /// Handle `DELETE` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void delete(String route, Function handler, {Middleware? use}) =>
      add('DELETE', route, handler, _middlewareList(use));

  /// Handle `CONNECT` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void connect(String route, Function handler, {Middleware? use}) =>
      add('CONNECT', route, handler, _middlewareList(use));

  /// Handle `OPTIONS` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void options(String route, Function handler, {Middleware? use}) =>
      add('OPTIONS', route, handler, _middlewareList(use));

  /// Handle `TRACE` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void trace(String route, Function handler, {Middleware? use}) =>
      add('TRACE', route, handler, _middlewareList(use));

  /// Handle `PATCH` request to [route] using [handler].
  ///
  /// Can obtain a [Middleware] via [use] for this route.
  void patch(String route, Function handler, {Middleware? use}) =>
      add('PATCH', route, handler, _middlewareList(use));

  /// Registers a [middleware] to use for all specified routes.
  ///
  /// You can not register a [Middleware] after you registered
  /// any route.
  void use(Middleware middleware) {
    if (_routeAdded) {
      throw ArgumentError(
          'Please use the "use()" method before adding any other routes.');
    }
    _middlewares.add(middleware);
  }

  final _middlewares = <Middleware>[];

  List<Middleware> _middlewareList(Middleware? use) {
    var list = <Middleware>[
      ..._middlewares,
      if (use != null) use,
    ];
    return list;
  }
}
