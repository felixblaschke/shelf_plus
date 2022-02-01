import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Abstraction of a websocket lifecycle
class WebSocketSession {
  /// The original websocket channel created by package web_socket_channel
  late WebSocketChannel channel;

  /// Invoked when web socket session is opened
  FutureOr<void> Function(WebSocketSession session)? onOpen;

  /// Invoked when web socket receives a message
  FutureOr<void> Function(WebSocketSession session, dynamic data)? onMessage;

  /// Invoked when web socket closes
  FutureOr<void> Function(WebSocketSession session)? onClose;

  /// Invoked web an error occurs
  FutureOr<void> Function(WebSocketSession session, dynamic error)? onError;

  /// Creates an instance of a web socket session. This instance needs to
  /// get return inside a ShelfPlus handler.
  ///
  /// Example:
  /// ```dart
  /// var app = Router().plus;
  ///
  /// app.get(
  ///     '/ws',
  ///     () => WebSocketSession(
  ///       onOpen: (session) => session.send('Hello WebSocket!'),
  ///     ),
  ///   );
  /// ```
  WebSocketSession({this.onOpen, this.onMessage, this.onClose, this.onError});

  /// Sends a message with [data] to the other endpoint
  void send(dynamic data) {
    channel.sink.add(data);
  }

  /// Closes the connection.
  /// To pass in a reason use `channel.sink.close()`.
  void close() {
    channel.sink.close();
  }

  /// Returns reference to the websocket sink
  WebSocketSink get sender => channel.sink;

  /// Initializer method called by webSocketHandler.
  /// You don't need to call this method manually.
  void init(WebSocketChannel webSocketChannel) {
    channel = webSocketChannel;

    /// Lifecycle of a websocket
    try {
      /// Open
      onOpen?.call(this);

      /// While connected
      channel.stream.listen((dynamic data) {
        onMessage?.call(this, data);
      }, onDone: () {
        /// On close
        onClose?.call(this);
      }, onError: (dynamic error) {
        /// On error
        onError?.call(this, error);
      });
    } catch (e) {
      /// If something goes wrong
      onError?.call(this, e);
      try {
        channel.sink.close();
        // ignore: empty_catches
      } catch (e) {}
    }
  }
}
