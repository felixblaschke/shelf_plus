import 'package:shelf/shelf.dart';

/// Merges multiple [Handler] into a cascade of handler.
/// Uses the shelf [Cascade] ruleset.
Handler cascade(List<Handler> handler) {
  var cascade = Cascade();
  for (var h in handler) {
    cascade = cascade.add(h);
  }
  return cascade.handler;
}
