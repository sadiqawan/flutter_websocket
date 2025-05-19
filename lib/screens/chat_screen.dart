import 'dart:html';
import 'package:flutter/material.dart';

class ChatClient extends StatefulWidget {
  const ChatClient({super.key});

  @override
  State<ChatClient> createState() => _ChatClientState();
}

class _ChatClientState extends State<ChatClient> {
  late WebSocket? _socket;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  bool _connected = false;



  // check the connection to local server

  void connect() {
    _socket = WebSocket('ws://localhost:8080');
    _socket!.onOpen.listen((event) {
      setState(() {
        _connected = true;
      });
    });
    _socket!.onMessage.listen((event) {
      setState(() {
        _messages.add(event.data.toString());
      });
    });

    _socket!.onClose.listen((event) {
      setState(() {
        _connected = false;
      });
    });

    _socket!.onError.listen((event) {
      print('Connection error');
    });
  }
// massage send to server
  void sendMessage() {
    if (_socket != null && _connected && _messageController.text.isNotEmpty) {
      _socket!.send(_messageController.text);
      setState(() {
        _messages.add("Me: ${_messageController.text}");
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Web Chat Client",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 20,),
            !_connected
                ? ElevatedButton(
                  onPressed: connect,
                  child: const Text("Connect to Server"),
                )
                : const Text(
                  "Connected",
                  style: TextStyle(color: Colors.green),
                ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(_messages[i]),
                        leading: Icon(Icons.person),
                        subtitle: Text('Replay form local server'),
                        trailing: Icon(Icons.check_box, color: Colors.green),
                        shape: OutlineInputBorder(),
                      ),
                    ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
