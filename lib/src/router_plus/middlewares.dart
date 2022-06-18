import 'dart:io';

import 'package:mime_type/mime_type.dart';
import 'package:shelf/shelf.dart';

/// Sets the content type header of the response to given [mimeType].
Middleware setContentType(String mimeType) => (Handler innerHandler) =>
    (Request request) async => (await innerHandler(request))
        .change(headers: {HttpHeaders.contentTypeHeader: mimeType});

/// Sets the content type header of the response to a mime-type that
/// matches the give [fileExtension].
Middleware typeByExtension(
  String fileExtension, {
  String unknownMimeType = 'application/unknown',
}) =>
    setContentType(mimeFromExtension(fileExtension) ?? unknownMimeType);

/// Changes the response headers in a way, browsers will handle the
/// http response as a download.
///
/// By default the browser will derive a filename from url and
/// content type. Optionally a fixed [filename] can be specified.
Middleware download({String? filename}) =>
    (Handler innerHandler) => (Request request) async {
          final response = await innerHandler(request);
          return response.change(headers: {
            'content-disposition':
                'attachment${filename != null ? '; filename=$filename' : ''}'
          });
        };
