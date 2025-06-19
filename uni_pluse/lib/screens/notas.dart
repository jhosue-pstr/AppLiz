import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  // Método para formatear la fecha como lo tenías originalmente
  DateTime _parseDate(String dateString) {
    try {
      return DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
        'en_US',
      ).parseUtc(dateString).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _loadTokenAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')?.trim(); // Limpia espacios

      // Debug: Verifica el token
      debugPrint('Token recuperado: $token');
      debugPrint(
        'Longitud del token: ${token?.length}',
      ); // Debería ser >100 chars

      if (token == null || token.isEmpty) {
        _showAuthError();
        return;
      }

      setState(() => _token = token);
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
        Uri.parse('https://appliz-backend-production.up.railway.app/api/notes'),
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
    if (_token == null || !_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://appliz-backend-production.up.railway.app/api/notes'),
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
          SnackBar(
            content: const Text('Nota guardada correctamente'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/notes/$noteId',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nota eliminada'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final updatedAt = note['updated_at'] != null
        ? _parseDate(note['updated_at'])
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _titleController.text = note['title'] ?? '';
          _contentController.text = note['content'] ?? '';
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note['title'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(note['id'] as int),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note['content'] ?? '',
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Última actualización: ${DateFormat('dd/MM/yyyy HH:mm').format(updatedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Notas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blueGrey[50],
        foregroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNotes),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Cargando tus notas...',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Título',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blueGrey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blueGrey[500]!,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.blueGrey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa un título';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contentController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Contenido',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blueGrey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blueGrey[500]!,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.blueGrey[50],
                              hintText: 'Escribe tu nota aquí...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el contenido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveNote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Guardar Nota',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _notes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_add,
                                size: 64,
                                color: Colors.blueGrey[300],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No tienes notas aún',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crea tu primera nota usando el formulario arriba',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(_notes[index]);
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
