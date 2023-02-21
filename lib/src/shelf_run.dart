import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

typedef OnStarted = void Function(Object address, int port);

/// The type [e] represents the error or exception that occurred.
typedef OnStartFailed = void Function(Object e);

/// Mechanism to quickly run a shelf app.
///
/// Requires an [init] function, that provides a shelf [Handler].
///
/// Can be configured with environment variables:
/// - SHELF_PORT: port to run (default 8080)
/// - SHELF_ADDRESS: address to bind to (default 'localhost')
/// - SHELF_HOTRELOAD: enable (true) or disable (false) hot reload (default true)
/// - SHELF_SHARED: enable (true) or disable (false) [sharing](https://api.dart.dev/stable/2.16.0/dart-io/HttpServer/bind.html#:~:text=The%20optional%20argument-,shared,-specifies%20whether%20additional) the underlying http server. Should be activated when serving in different isolates. (default false)
///
/// The default values can be overridden by setting [defaultBindPort],
/// [defaultBindAddress], [defaultEnableHotReload] or [defaultShared].
Future<ShelfRunContext> shelfRun(
  FutureOr<shelf.Handler> Function() init, {
  int defaultBindPort = 8080,
  Object defaultBindAddress = 'localhost',
  bool defaultEnableHotReload = true,
  bool defaultShared = false,
  SecurityContext? securityContext,
  OnStarted? onStarted,
  OnStartFailed? onStartFailed,
}) async {
  var context = ShelfRunContext();

  var useHotReload = defaultEnableHotReload;

  if (_env('SHELF_HOTRELOAD')?.toLowerCase() == 'false') {
    useHotReload = false;
  }

  final catchDelegate = onStartFailed ?? (e) => throw e; // rethrow by default

  if (useHotReload) {
    withHotreload(() async {
      try {
        final server = await _createServer(
          init,
          defaultBindPort: defaultBindPort,
          defaultBindAddress: defaultBindAddress,
          defaultShared: defaultShared,
          securityContext: securityContext,
          onStarted: onStarted,
        );
        context._server = server;
      } catch (e) {
        catchDelegate(e);
      }
      return Future.value(context._server);
    });
  } else {
    try {
      await _createServer(
        init,
        defaultBindPort: defaultBindPort,
        defaultBindAddress: defaultBindAddress,
        defaultShared: defaultShared,
        securityContext: securityContext,
        onStarted: onStarted,
      );
    } catch (e) {
      catchDelegate(e);
    }
  }

  return context;
}

/// Creates a default IO server
Future<HttpServer> _createServer(
  FutureOr<shelf.Handler> Function() init, {
  required int defaultBindPort,
  required Object defaultBindAddress,
  required bool defaultShared,
  SecurityContext? securityContext,
  OnStarted? onStarted,
}) async {
  var port = _env('SHELF_PORT')?.toInt() ?? defaultBindPort;
  var address = _env('SHELF_ADDRESS') ?? defaultBindAddress;
  var shared = _env('SHELF_SHARED')?.toBool() ?? defaultShared;

  var handler = await init();
  final server = await io.serve(handler, address, port,
      shared: shared, securityContext: securityContext);
  if (onStarted == null) {
    stdout.writeln('shelfRun HTTP service running on port ${server.port}');
  } else {
    onStarted(address, port);
  }
  return server;
}

/// Helper for looking up environment variable
String? _env(String key) =>
    Platform.environment[key.toUpperCase()] ??
    Platform.environment[key.toLowerCase()];

class ShelfRunContext {
  HttpServer? _server;

  /// Stops the shelfRun
  Future<void> close() async {
    await _server?.close();
  }

  ShelfRunContext();
}

extension on String {
  toBool() => toLowerCase().trim() == 'true';
  toInt() => int.parse(this);
}
