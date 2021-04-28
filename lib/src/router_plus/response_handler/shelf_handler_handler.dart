import 'package:shelf/shelf.dart';

import 'response_handler.dart';

/// Processes a shelf [Handler] and returns it shelf [Response]
ResponseHandler get shelfHandlerHandler =>
    (Request request, dynamic data) async {
      if (data is Handler) {
        return await data.call(request);
      }
      return null;
    };
