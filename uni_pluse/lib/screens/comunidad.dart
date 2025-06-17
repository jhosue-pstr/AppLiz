import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ComunidadScreen extends StatefulWidget {
  final int userId;

  const ComunidadScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;
  String? _token;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndChats();
  }

  Future<void> _loadTokenAndChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        _navigateToLogin();
        return;
      }

      setState(() {
        _token = token;
      });

      await _fetchChats();
    } catch (e) {
      _showError('Error al cargar chats: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchChats() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/chats'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _chats = List<dynamic>.from(data);
        });
      } else if (response.statusCode == 401) {
        _navigateToLogin();
      } else {
        _showError('Error al cargar chats: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToChat(int chatId, String chatName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          chatName: chatName,
          userId: widget.userId,
          token: _token!,
        ),
      ),
    );
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NewChatModal(
        userId: widget.userId,
        token: _token!,
        onChatCreated: (chatId, chatName) {
          _navigateToChat(chatId, chatName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(_chats, _navigateToChat),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchChats,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _buildChatCard(chat, isDark);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_chat.png', width: 200, height: 200),
          const SizedBox(height: 20),
          Text(
            'No tienes chats aún',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          const Text(
            'Empieza una nueva conversación',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startNewChat,
            child: const Text('Nuevo Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat, bool isDark) {
    final lastMessage = chat['last_message'];
    final unreadCount = chat['unread_count'] ?? 0;
    final isGroup = chat['is_group'] ?? false;
    final participants = chat['participants'] ?? [];
    final lastMessageTime = chat['last_message_at'] != null
        ? DateFormat(
            'HH:mm',
          ).format(DateTime.parse(chat['last_message_at']).toLocal())
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToChat(chat['id'], chat['name']),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    child: isGroup
                        ? const Icon(Icons.group, size: 28)
                        : participants.isNotEmpty &&
                              participants[0]['avatar_url'] != null
                        ? CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(
                              participants[0]['avatar_url'],
                            ),
                          )
                        : const Icon(Icons.person, size: 28),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.grey[900]! : Colors.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat['name'] ?? 'Chat sin nombre',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          lastMessageTime,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (lastMessage != null)
                      Text(
                        '${lastMessage['user_name']}: ${lastMessage['content']}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text(
                        'No hay mensajes',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  final int chatId;
  final String chatName;
  final int userId;
  final String token;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Mostrar información del chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: 10, // Reemplazar con mensajes reales
              itemBuilder: (context, index) {
                return _buildMessageBubble(index % 2 == 0);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Este es un mensaje de ejemplo que puede ser largo o corto dependiendo de lo que el usuario escriba',
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Adjuntar archivo/imagen
            },
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Enviar mensaje
            },
          ),
        ],
      ),
    );
  }
}

class NewChatModal extends StatelessWidget {
  final int userId;
  final String token;
  final Function(int, String) onChatCreated;

  const NewChatModal({
    Key? key,
    required this.userId,
    required this.token,
    required this.onChatCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          const Text(
            'Nuevo Chat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Reemplazar con lista de contactos
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Contacto ${index + 1}'),
                  subtitle: const Text('Última conexión: hoy'),
                  onTap: () {
                    // Crear chat individual
                    onChatCreated(index + 1, 'Contacto ${index + 1}');
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Nuevo grupo'),
            onTap: () {
              Navigator.pop(context);
              _showCreateGroupDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear nuevo grupo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Seleccionar participantes:'),
              // Lista de checkboxes para seleccionar participantes
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para crear grupo
                Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}

class ChatSearchDelegate extends SearchDelegate {
  final List<dynamic> chats;
  final Function(int, String) onChatSelected;

  ChatSearchDelegate(this.chats, this.onChatSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = chats.where((chat) {
      return chat['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          (chat['last_message'] != null &&
              chat['last_message']['content'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ));
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return ListTile(
          leading: CircleAvatar(
            child: chat['is_group']
                ? const Icon(Icons.group)
                : const Icon(Icons.person),
          ),
          title: Text(chat['name']),
          subtitle: chat['last_message'] != null
              ? Text(chat['last_message']['content'])
              : const Text('No hay mensajes'),
          onTap: () {
            onChatSelected(chat['id'], chat['name']);
            close(context, null);
          },
        );
      },
    );
  }
}
