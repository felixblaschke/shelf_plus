import 'dart:io';

import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Converts a [String] to shelf [Response]
ResponseHandler get stringHandler => (Request request, dynamic data) {
      if (data is String) {
        return Response.ok(data, headers: {
          HttpHeaders.contentTypeHeader: ContentType.text.mimeType
        });
      }
      return null;
    };
