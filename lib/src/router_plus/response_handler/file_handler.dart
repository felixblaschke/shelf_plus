import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

import 'response_handler.dart';

/// Serves the given [File] using shelf_static package.
ResponseHandler get fileHandler => (Request request, dynamic file) {
      if (file is File) {
        if (file.existsSync()) {
          return createFileHandler(file.path, url: request.url.path)
              .call(request);
        } else {
          return Response.notFound('');
        }
      }
      return null;
    };
