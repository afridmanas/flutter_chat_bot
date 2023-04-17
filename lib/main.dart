import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String API_URL = "https://api.chatgpt.com/query";

void main() {
  runApp(ChatBot());
}

class ChatBot extends StatefulWidget {
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  TextEditingController _controller = TextEditingController();
  List<Map> _messages = [];

  Future<Map> sendMessage(String message) async {
    try {
      final response = await http.post(Uri.parse(API_URL), body: {
        'message': message
      }, headers: {
        'Authorization': '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'
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("chatgpt api error :Failed to load response");
      }
    } catch (e) {
      throw Exception("chatgpt api error : $e");
    }
  }

  void _addMessage(Map message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ChatBot'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = _messages[index];
                  final isBot = message['sender'] == 'bot';
                  return Container(
                    alignment:
                        isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(message['text']),
                      ),
                    ),
                  );
                },
                reverse: true,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter a message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      final text = _controller.text;
                      if (text.isEmpty) {
                        return;
                      }
                      _controller.clear();
                      _addMessage({'sender': 'user', 'text': text});
                      try {
                        final response = await sendMessage(text);
                        _addMessage(
                            {'sender': 'bot', 'text': response['response']});
                      } catch (e) {
                        _addMessage({
                          'sender': 'bot',
                          'text': 'Oops! Something went wrong.'
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
