import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Serializes [Map] and [List] to a shelf [Response]
ResponseHandler get jsonHandler => (Request request, dynamic data) {
      /// Try to call `.toJson()` method and return result
      var invokeResult = _invokeToJsonMethod(data);
      if (invokeResult != null) {
        return invokeResult;
      }

      /// Serialize maps
      if (data is Map<String, dynamic>) {
        return _serializedJsonResponse(data);
      }

      /// Serialize lists
      if (data is List<dynamic>) {
        /// Try to invoke '.toJson()' on every item
        final invokeList = data
            .map((item) => _invokeToJsonMethod(item))
            .toList(growable: false);

        /// Everytime item successfully transformed via '.toJson'?
        var everyItemIsToJsonInvokable =
            invokeList.every((item) => item != null);

        if (everyItemIsToJsonInvokable) {
          return invokeList;
        } else {
          return _serializedJsonResponse(data);
        }
      }

      /// Handle Iterable by turning them into lists (process with next iteration)
      if (data is Iterable<dynamic>) {
        return data.toList(growable: false);
      }
      return null;
    };

Response _serializedJsonResponse(dynamic object) {
  return Response.ok(
    jsonEncode(object),
    headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
  );
}

Object? _invokeToJsonMethod(dynamic object) {
  try {
    if (object.toJson != null) {
      return object.toJson();
    }
  } on NoSuchMethodError catch (e) {
    if (!e.toString().contains("'toJson'")) {
      rethrow;
    }
  }
  return null;
}

// TODO serialize Iterable<Person>
// TODO serialize List<Person>
