import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotesScreen extends StatefulWidget {
  final int userId;

  const NotesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    try {
      // 1. Cargar el token desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        _showAuthError();
        return;
      }

      setState(() {
        _token = token;
      });

      // 2. Cargar las notas
      await _fetchNotes();
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchNotes() async {
    if (_token == null) {
      _showAuthError();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/notes'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _notes = List<Map<String, dynamic>>.from(data['notes'] ?? []);
        });
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al cargar notas: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _saveNote() async {
    if (_token == null ||
        _titleController.text.isEmpty ||
        _contentController.text.isEmpty) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/notes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'title': _titleController.text,
          'content': _contentController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota guardada correctamente')),
        );
        _titleController.clear();
        _contentController.clear();
        await _fetchNotes();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al guardar la nota: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _deleteNote(int noteId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:5000/api/notes/$noteId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nota eliminada')));
        await _fetchNotes();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al eliminar la nota: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  void _showAuthError() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión expirada, por favor inicia sesión nuevamente'),
      ),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNotes),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Contenido',
                          border: OutlineInputBorder(),
                          hintText: 'Escribe tu nota aquí...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveNote,
                        child: const Text('Guardar Nota'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _notes.isEmpty
                      ? const Center(child: Text('No hay notas disponibles'))
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text(note['title'] ?? 'Sin título'),
                                subtitle: Text(note['content'] ?? ''),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteNote(note['id'] as int),
                                ),
                                onTap: () {
                                  _titleController.text = note['title'] ?? '';
                                  _contentController.text =
                                      note['content'] ?? '';
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
