import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Chat',
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final WebSocketChannel _channel;
  final _scrollController = ScrollController();
  final _messages = <String>[];
  final _messageController = TextEditingController();
  final _messageFocus = FocusNode();

  @override
  void initState() {
    // Establish connection
    _createConnection();
    super.initState();
  }

  void _createConnection() async {
    // Connect to web socket
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));

    // Remember all messages that passed the channel
    _channel.stream.listen(
        (message) => setState(() {
              _messages.add(message);
              _scrollToBottom();
            }),
        // If something goes wrong...
        onError: (error) => setState(() => _messages.add('Error: $error')));
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  void _send() {
    if (_messageController.text.isNotEmpty) {
      _channel.sink.add(_messageController.text);
      _messageController.text = '';
    }
    _messageFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ChatBubblesScrollView(
              scrollController: _scrollController,
              messages: _messages,
            ),
          ),
          ChatMessageSubmitForm(
              messageFocus: _messageFocus,
              messageController: _messageController,
              send: () => _send())
        ],
      ),
    ));
  }
}

class ChatMessageSubmitForm extends StatelessWidget {
  const ChatMessageSubmitForm({
    super.key,
    required this.messageFocus,
    required this.messageController,
    required this.send,
  });

  final FocusNode messageFocus;
  final TextEditingController messageController;
  final void Function() send;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: TextField(
              focusNode: messageFocus,
              decoration: const InputDecoration(label: Text('Message')),
              controller: messageController,
              onSubmitted: (_) => send(),
            )),
            const SizedBox(width: 20),
            ElevatedButton(onPressed: () => send(), child: const Text('Send')),
          ],
        ),
      ),
    );
  }
}

/// Scrollable view that list all messages as bubbles
class ChatBubblesScrollView extends StatelessWidget {
  const ChatBubblesScrollView({
    super.key,
    required ScrollController scrollController,
    required List<String> messages,
  })  : _scrollController = scrollController,
        _messages = messages;

  final ScrollController _scrollController;
  final List<String> _messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: (context, index) => Bubble(_messages[index]),
    );
  }
}

/// Container that displays the message text
class Bubble extends StatelessWidget {
  const Bubble(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(message),
          )),
    );
  }
}
