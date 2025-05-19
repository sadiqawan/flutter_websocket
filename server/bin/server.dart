import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('WebSocket Server running on ws://${server.address.address}:${server.port}');

  final clients = <WebSocket>[];

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      clients.add(socket);

      socket.listen(
            (message) {
          print('Received: $message');
          for (var client in clients) {
            if (client != socket) {
              client.add(message);
            }
          }
        },
        onDone: () {
          print('Client disconnected');
          clients.remove(socket);
        },
        onError: (error) {
          print('WebSocket error: $error');
          clients.remove(socket);
        },
      );
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  }
}
