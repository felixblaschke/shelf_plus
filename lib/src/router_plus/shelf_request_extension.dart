import 'package:shelf/shelf.dart';

extension ShelfRequestExtension on Request {
  /// Returns the value of the route parameter identified by [name].
  String routeParameter(String name) {
    var parameters = context['shelf_router/params'] as Map<String, String>;
    return parameters[name] ?? '';
  }
}
