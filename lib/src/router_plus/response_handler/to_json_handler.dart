import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Converts objects with a `toJson()` method to [Map] or [List].
///
/// Typical code generators will generate a `toJson()` method.
ResponseHandler get toJsonHandler => (Request request, dynamic object) {
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
    };
