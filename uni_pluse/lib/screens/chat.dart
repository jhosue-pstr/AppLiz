import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final String chatName;
  final int userId;
  final String token;
  final bool isGroup;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.userId,
    required this.token,
    required this.isGroup,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/chats/${widget.chatId}/messages'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = data['data'] ?? [];
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        print('Error cargando mensajes: ${response.body}');
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/chats/${widget.chatId}/messages'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': text}),
    );

    if (response.statusCode == 201) {
      _messageController.clear();
      await _fetchMessages(); // Recargar mensajes
    } else {
      print('Error enviando mensaje: ${response.body}');
    }
  }

  DateTime _parseDate(String sentAt) {
    try {
      return DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
        'en_US',
      ).parseUtc(sentAt).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isMe = message['user_id'] == widget.userId;
    final sentTime = _parseDate(message['sent_at'] ?? '');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe && widget.isGroup)
            CircleAvatar(
              backgroundColor: Colors.blueGrey[200],
              child: Text(
                message['user_name']?.substring(0, 1) ?? 'U',
                style: TextStyle(color: Colors.white),
              ),
              radius: 16,
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).primaryColor.withOpacity(0.9)
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 12 : 0),
                  topRight: Radius.circular(isMe ? 0 : 12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (widget.isGroup && !isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message['user_name'] ?? 'Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                  Text(
                    message['content'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(sentTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchMessages),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueGrey[50]!, Colors.grey[100]!],
                ),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No hay mensajes aún',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Envía el primer mensaje',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageItem(_messages[index]);
                      },
                    ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
