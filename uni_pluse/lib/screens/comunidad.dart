import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ComunidadScreen extends StatefulWidget {
  final int userId;
  final String name;

  const ComunidadScreen({Key? key, required this.userId, required this.name})
    : super(key: key);

  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;
  String? _token;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _loadTokenAndChats();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  Future<void> _loadTokenAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _token = token;
    await _connectSocket();
    await _fetchChats();
    setState(() => _isLoading = false);
  }

  Future<void> _connectSocket() async {
    _socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $_token'},
    });
    _socket?.connect();

    _socket?.on('connect', (_) => print('Socket conectado'));
    _socket?.on('new_message', (_) => _fetchChats());
    _socket?.on('disconnect', (_) => print('Socket desconectado'));
  }

  Future<void> _fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/chats'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _chats = json.decode(response.body)['data'] ?? [];
        });
      } else {
        print('Error al obtener chats: ${response.body}');
      }
    } catch (e) {
      print('Error en _fetchChats: $e');
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
        'en_US',
      ).parseUtc(dateString).toLocal();
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  void _navigateToChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chat['id'],
          chatName:
              chat['name'] ??
              (chat['is_group'] == 1 ? 'Grupo' : 'Chat privado'),
          userId: widget.userId,
          token: _token!,
          isGroup: chat['is_group'] == 1,
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(chat['is_group'] == 1 ? Icons.group : Icons.person),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(
          chat['name'] ??
              (chat['is_group'] == 1 ? 'Grupo sin nombre' : 'Chat privado'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          chat['last_message_content'] ?? 'Sin mensajes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chat['last_message_at'] != null)
              Text(
                DateFormat('HH:mm').format(_parseDate(chat['last_message_at'])),
                style: TextStyle(fontSize: 12),
              ),
            if (chat['unread_count'] != null && chat['unread_count'] > 0)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat['unread_count'].toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        onTap: () => _navigateToChat(chat),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.blue),
                title: Text('Nuevo chat privado'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserInputDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.group_add, color: Colors.blue),
                title: Text('Nuevo grupo'),
                onTap: () {
                  Navigator.pop(context);
                  _showGroupCreationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo chat privado'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'ID del otro usuario'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final otherId = int.tryParse(controller.text);
                if (otherId == null || otherId == widget.userId) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('ID inválido')));
                  return;
                }

                final res = await http.post(
                  Uri.parse('http://127.0.0.1:5000/api/chats/private'),
                  headers: {
                    'Authorization': 'Bearer $_token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({'user_id': otherId}),
                );

                if (res.statusCode == 200) {
                  await _fetchChats();
                  Navigator.pop(context);
                } else {
                  final error =
                      json.decode(res.body)['error'] ?? 'Error desconocido';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $error')));
                }
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showGroupCreationDialog() async {
    // Obtener usuarios solo cuando se va a crear un grupo
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/users'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al obtener usuarios')));
        return;
      }

      final users = json.decode(response.body)['users'] ?? [];
      final otherUsers = users.where((u) => u['id'] != widget.userId).toList();
      final selectedUsers = <int>[];
      final nameController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Crear grupo'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del grupo',
                        ),
                      ),
                      SizedBox(height: 10),
                      ...otherUsers.map(
                        (user) => CheckboxListTile(
                          title: Text(user['name']),
                          value: selectedUsers.contains(user['id']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedUsers.add(user['id']);
                              } else {
                                selectedUsers.remove(user['id']);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          selectedUsers.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Nombre y participantes son requeridos',
                            ),
                          ),
                        );
                        return;
                      }

                      final res = await http.post(
                        Uri.parse('http://127.0.0.1:5000/api/chats/group'),
                        headers: {
                          'Authorization': 'Bearer $_token',
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'name': nameController.text,
                          'participants': selectedUsers,
                        }),
                      );

                      if (res.statusCode == 201) {
                        await _fetchChats();
                        Navigator.pop(context);
                      } else {
                        final error =
                            json.decode(res.body)['error'] ??
                            'Error al crear grupo';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    },
                    child: Text('Crear grupo'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _isLoading = true);
              await _fetchChats();
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? Center(child: Text('No tienes chats aún'))
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchChats();
              },
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) => _buildChatItem(_chats[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatOptions,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
