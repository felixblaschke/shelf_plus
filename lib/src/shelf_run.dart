import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

/// Mechanism to quickly run a shelf app.
///
/// Requires an [init] function, that provides a shelf [Handler].
///
/// Can be configured with environment variables:
/// - SHELF_PORT: port to run (default 8080)
/// - SHELF_ADDRESS: address to bind to (default 'localhost')
/// - SHELF_HOTRELOAD: enable (true) or disable (false) hot reload (default true)
///
/// The default values can be overridden by setting [defaultBindPort],
/// [defaultBindAddress] or [defaultEnableHotReload].
Future<ShelfRunContext> shelfRun(
  FutureOr<shelf.Handler> Function() init, {
  int defaultBindPort = 8080,
  String defaultBindAddress = 'localhost',
  bool defaultEnableHotReload = true,
}) async {
  var context = ShelfRunContext();

  var useHotReload = defaultEnableHotReload;

  if (_env('SHELF_HOTRELOAD')?.toLowerCase() == 'false') {
    useHotReload = false;
  }

  if (useHotReload) {
    withHotreload(() async {
      final server = await _createServer(init,
          defaultBindPort: defaultBindPort,
          defaultBindAddress: defaultBindAddress);
      context._server = server;
      return server;
    });
  } else {
    await _createServer(init,
        defaultBindPort: defaultBindPort,
        defaultBindAddress: defaultBindAddress);
  }

  return context;
}

/// Creates a default IO server
Future<HttpServer> _createServer(
  FutureOr<shelf.Handler> Function() init, {
  required int defaultBindPort,
  required String defaultBindAddress,
}) async {
  var port = _env('SHELF_PORT')?.toInt() ?? defaultBindPort;
  var address = _env('SHELF_ADDRESS') ?? defaultBindAddress;

  var handler = await init();
  final server = await io.serve(handler, address, port);
  print('shelfRun HTTP service running on port ${server.port}');
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
