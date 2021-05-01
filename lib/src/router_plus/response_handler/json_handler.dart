import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Serializes [Map] and [List] to a shelf [Response]
ResponseHandler get jsonHandler => (Request request, dynamic data) {
      if (data is Map<String, dynamic> || data is List<dynamic>) {
        return Response.ok(
          jsonEncode(data),
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
        );
      }

      if (data is Iterable<dynamic>) {
        return data.toList(growable: false);
      }
      return null;
    };

// TODO serialize Iterable<Person>
// TODO serialize List<Person>
// TODO maybe combine with toJson handler
