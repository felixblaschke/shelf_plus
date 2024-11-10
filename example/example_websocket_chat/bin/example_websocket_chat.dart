import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  // HTML-based web client
  app.get('/', () => File('public/html_client.html'));

  // Track connected clients
  var users = <WebSocketSession>[];

  // Web socket route
  app.get(
    '/ws',
    () => WebSocketSession(
      onOpen: (ws) {
        // Join chat
        users.add(ws);
        users
            .where((user) => user != ws)
            .forEach((user) => user.send('A new user joined the chat.'));
      },
      onClose: (ws) {
        // Leave chat
        users.remove(ws);
        for (var user in users) {
          user.send('A user has left.');
        }
      },
      onMessage: (ws, dynamic data) {
        // Deliver messages to all users
        for (var user in users) {
          user.send(data);
        }
      },
    ),
  );

  return app.call;
}
