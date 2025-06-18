import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _loadTokenAndChats();
    _initSocket();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    _socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    _socket?.connect();

    _socket?.on('connect', (_) {
      print('Conectado al socket');
    });

    _socket?.on('new_message', (data) {
      _fetchChats(); // Actualizar lista cuando llega nuevo mensaje
    });

    _socket?.on('disconnect', (_) => print('Desconectado del socket'));
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString).toLocal();
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  Future<void> _loadTokenAndChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null || _token!.isEmpty) {
        _navigateToLogin();
        return;
      }

      await _fetchChats();
    } catch (e) {
      _showError('Error al cargar datos');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      } else if (response.statusCode == 401) {
        _navigateToLogin();
      }
    } catch (e) {
      _showError('Error al cargar chats');
    }
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/users'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      return json.decode(response.body)['users'] ?? [];
    } catch (e) {
      _showError('Error cargando usuarios');
      return [];
    }
  }

  Future<void> _createPrivateChat(int otherUserId) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/chats/private'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'user_id': otherUserId}),
      );

      if (response.statusCode == 201) {
        await _fetchChats();
        _showError('Chat creado exitosamente', isError: false);
      } else {
        _showError('Error al crear chat: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _createGroupChat(String name, List<int> participants) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/chats/group'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name, 'participants': participants}),
      );

      if (response.statusCode == 201) {
        await _fetchChats();
        _showError('Grupo creado exitosamente', isError: false);
      } else {
        _showError('Error al crear grupo: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  void _navigateToChat(int chatId, String chatName, bool isGroup) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': chatId,
        'chatName': chatName,
        'isGroup': isGroup,
        'userId': widget.userId,
        'token': _token,
      },
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildChatItem(dynamic chat) {
    final isGroup = chat['is_group'] == 1 || chat['is_group'] == true;
    final lastMessage =
        chat['last_message_content']?.toString() ?? 'No hay mensajes';
    final lastMessageSender = chat['last_message_sender']?.toString() ?? '';
    final time = chat['last_message_at'] != null
        ? DateFormat('HH:mm').format(_parseDate(chat['last_message_at']))
        : '';
    final unreadCount = chat['unread_count'] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(isGroup ? Icons.group : Icons.person, color: Colors.blue),
        ),
        title: Text(chat['name'] ?? 'Chat'),
        subtitle: Text(
          isGroup && lastMessageSender.isNotEmpty
              ? '$lastMessageSender: $lastMessage'
              : lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        onTap: () =>
            _navigateToChat(chat['id'], chat['name'] ?? 'Chat', isGroup),
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
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo chat privado'),
          content: TextField(
            controller: userIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'ID del usuario',
              hintText: 'Ingrese el ID del usuario',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Crear chat'),
              onPressed: () {
                final userId = int.tryParse(userIdController.text);
                if (userId == null) {
                  _showError('Ingrese un ID válido');
                  return;
                }
                if (userId == widget.userId) {
                  _showError('No puedes chatear contigo mismo');
                  return;
                }
                _createPrivateChat(userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showGroupCreationDialog() async {
    final users = await _fetchUsers();
    final otherUsers = users
        .where((user) => user['id'] != widget.userId)
        .toList();
    final nameController = TextEditingController();
    final selectedUsers = <int>[];

    if (otherUsers.isEmpty) {
      _showError('No hay usuarios disponibles para grupo');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Crear grupo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del grupo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Seleccionar participantes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...otherUsers.map((user) {
                      return CheckboxListTile(
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
                        title: Text(user['name']),
                        secondary: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            user['name'][0].toUpperCase(),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Crear grupo'),
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      _showError('Ingrese un nombre para el grupo');
                      return;
                    }
                    if (selectedUsers.isEmpty) {
                      _showError('Seleccione al menos un participante');
                      return;
                    }
                    _createGroupChat(nameController.text, selectedUsers);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchChats().then((_) => setState(() => _isLoading = false));
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes chats',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para comenzar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchChats,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8, bottom: 80),
                itemCount: _chats.length,
                itemBuilder: (context, index) => _buildChatItem(_chats[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _showNewChatOptions,
      ),
    );
  }
}
