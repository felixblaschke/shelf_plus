import 'dart:async';

import 'package:shelf/shelf.dart';

import 'binary_handler.dart';
import 'file_handler.dart';
import 'json_handler.dart';
import 'shelf_handler_handler.dart';
import 'string_handler.dart';

/// Model for converting an object into another one.
///
/// A [ResponseHandler] returns null if it can't process the
/// [data]. The [ResponseHandler] indicates that it is able and successfully
/// converted the [data] by return a non-null value.
typedef ResponseHandler = FutureOr<Object?> Function(
    Request request, dynamic data);

/// Returns all [ResponseHandler] associated with the [request].
List<ResponseHandler> _associatedResponseHandler(Request request) {
  return request.context['shelf_plus/response_handler']
          as List<ResponseHandler>? ??
      <ResponseHandler>[];
}

extension ResponseHandlerToMiddleware on ResponseHandler {
  /// Creates a [Middleware] that registers this [ResponseHandler] for later
  /// use.
  Middleware get middleware => addResponseHandler([this]);
}

Middleware addResponseHandler(List<ResponseHandler> handler) {
  return (Handler innerHandler) => (Request request) async {
        return await innerHandler(request.change(context: {
          'shelf_plus/response_handler': [
            ..._associatedResponseHandler(request),
            ...handler
          ]
        }));
      };
}

var _defaultHandlers = <ResponseHandler>[
  stringHandler,
  binaryHandler,
  jsonHandler,
  shelfHandlerHandler,
  fileHandler,
];

/// Resolves a shelf [Response] from generic [result]
/// based on registered [ResponseHandler].
Future<Response> resolveResponse(Request request, dynamic result) async {
  var handlers = <ResponseHandler>[
    ..._defaultHandlers,
    ..._associatedResponseHandler(request),
  ];

  var tries = 0;

  /// Repeat until result type is shelf [Response]
  while (result is! Response) {
    var resultHandled = false;

    /// Iterate over all registered handlers
    for (var handler in handlers) {
      var handlerResult = await handler(request, result);
      if (handlerResult != null) {
        result = handlerResult;
        resultHandled = true;
        break;
      }
    }
    if (!resultHandled) {
      throw ArgumentError(
          'No response handler found to handle response type: $result');
    }
    if (++tries >= _maxTries) {
      throw ArgumentError('Can not resolve response.');
    }
  }
  return result;
}

const _maxTries = 20;
