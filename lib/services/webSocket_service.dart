import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  late WebSocketChannel channel;

  WebSocketService(this.url);

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void listen(void Function(dynamic message) onMessage) {
    channel.stream.listen(onMessage, onError: (error) {
      //print('WebSocket error: $error');
    }, onDone: () {
      // print('WebSocket connection closed');
    });
  }

  void disconnect() {
    channel.sink.close();
  }
}
