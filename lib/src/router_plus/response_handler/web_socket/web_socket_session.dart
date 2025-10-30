import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Abstraction of a websocket lifecycle
class WebSocketSession {
  /// The original websocket channel created by package web_socket_channel
  late WebSocketChannel channel;

  /// The subprotocol negotiated between client and server
  late String? subprotocol;

  /// The list of subprotocols supported by the server
  ///
  /// During WebSocket handshake, the server will select the first protocol
  /// from the client's list that also appears in this list. If no match is
  /// found, the connection may be rejected by the client.
  final Iterable<String>? protocols;

  /// Invoked when web socket session is opened
  FutureOr<void> Function(WebSocketSession session)? onOpen;

  /// Invoked when web socket receives a message
  FutureOr<void> Function(WebSocketSession session, dynamic data)? onMessage;

  /// Invoked when web socket closes
  FutureOr<void> Function(WebSocketSession session)? onClose;

  /// Invoked when an error occurs
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
  ///
  /// To support subprotocol negotiation, specify the allowed protocols:
  /// ```dart
  /// app.get(
  ///     '/ws',
  ///     () => WebSocketSession(
  ///       protocols: ['chat', 'superchat'],
  ///       onOpen: (session) {
  ///         print('Negotiated: ${session.subprotocol}');
  ///       },
  ///     ),
  ///   );
  /// ```
  WebSocketSession({
    this.onOpen,
    this.onMessage,
    this.onClose,
    this.onError,
    this.protocols,
  });

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
  void init(WebSocketChannel webSocketChannel, [String? subprotocol]) {
    channel = webSocketChannel;
    this.subprotocol = subprotocol;

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
