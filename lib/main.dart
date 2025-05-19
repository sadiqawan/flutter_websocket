import 'dart:html';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatClient(),
    );
  }
}
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
      appBar: AppBar(title: const Text("Web Chat Client")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            !_connected
                ? ElevatedButton(
                onPressed: connect, child: const Text("Connect to Server"))
                : const Text("Connected", style: TextStyle(color: Colors.green)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (_, i) => ListTile(title: Text(_messages[i])),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message"),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}