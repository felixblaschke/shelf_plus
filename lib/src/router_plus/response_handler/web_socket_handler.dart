import 'package:shelf_plus/shelf_plus.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_web_socket;
import 'package:web_socket_channel/web_socket_channel.dart';

ResponseHandler get webSocketHandler =>
    (Request request, dynamic maybeWebSocketSession) {
      if (maybeWebSocketSession is WebSocketSession) {
        return shelf_web_socket
            .webSocketHandler((WebSocketChannel webSocketChannel) {
          maybeWebSocketSession.init(webSocketChannel);
        });
      }
      return null;
    };
