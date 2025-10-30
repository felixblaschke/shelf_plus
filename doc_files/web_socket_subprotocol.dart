import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  // #begin
  app.get(
    '/ws',
    () => WebSocketSession(
      protocols: ['chat', 'superchat'],
      onOpen: (ws) {
        if (ws.subprotocol != null) {
          print('Negotiated subprotocol: ${ws.subprotocol}');
        }
      },
    ),
  );
  // #end

  return app.call;
}
