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
      return null;
    };
