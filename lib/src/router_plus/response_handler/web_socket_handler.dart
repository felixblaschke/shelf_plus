import 'package:shelf_plus/shelf_plus.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_web_socket;

ResponseHandler get webSocketHandler =>
    (Request request, dynamic maybeWebSocketSession) {
      if (maybeWebSocketSession is WebSocketSession) {
        return shelf_web_socket.webSocketHandler(
          (webSocketChannel, subprotocol) {
            maybeWebSocketSession.init(webSocketChannel, subprotocol);
          },
          protocols: maybeWebSocketSession.protocols,
        );
      }
      return null;
    };
