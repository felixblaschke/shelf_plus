import 'dart:typed_data';

import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Converts a binary structure to shelf [Response] as octet-stream
ResponseHandler get binaryHandler => (Request request, dynamic data) async {
      if (data is Uint8List || data is Stream<List<int>>) {
        return Response.ok(data,
            headers: {'content-type': 'application/octet-stream'});
      }
      return null;
    };
