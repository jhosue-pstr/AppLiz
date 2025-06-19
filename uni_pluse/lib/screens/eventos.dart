import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  final int userId;

  const EventsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _selectedEvents = [];
  String? _token;
  bool _isLoading = true;
  bool _showEventForm = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int? _editingEventId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
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
      await _fetchEvents();
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchEvents() async {
    if (_token == null) {
      _showAuthError();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/events',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _events = List<Map<String, dynamic>>.from(data);
          _updateSelectedEvents(_selectedDay);
        });
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  void _updateSelectedEvents(DateTime day) {
    setState(() {
      _selectedEvents = _events.where((event) {
        final eventDate = DateTime.parse(event['start_datetime'] ?? '');
        return isSameDay(eventDate, day);
      }).toList();
    });
  }

  Future<void> _saveEvent() async {
    if (_token == null || _titleController.text.isEmpty) {
      return;
    }

    try {
      final formattedDate = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).format(_selectedDay);
      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'start_datetime': formattedDate,
        'location': _locationController.text,
      };

      final response = _editingEventId == null
          ? await http.post(
              Uri.parse(
                'https://appliz-backend-production.up.railway.app/api/events',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: json.encode(eventData),
            )
          : await http.put(
              Uri.parse(
                'https://appliz-backend-production.up.railway.app/api/events/$_editingEventId',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: json.encode(eventData),
            );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento guardado correctamente')),
        );
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        await _fetchEvents();
        setState(() {
          _showEventForm = false;
          _editingEventId = null;
        });
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al guardar el evento: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/events/$eventId',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
        await _fetchEvents();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al eliminar el evento: ${response.statusCode}');
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
        title: const Text('Mis Eventos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchEvents),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _updateSelectedEvents(selectedDay);
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: (day) => _events.where((event) {
                          final eventDate = DateTime.parse(
                            event['start_datetime'] ?? '',
                          );
                          return isSameDay(eventDate, day);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Eventos para ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _selectedEvents.isEmpty
                          ? const Center(
                              child: Text('No hay eventos para este día'),
                            )
                          : ListView.builder(
                              itemCount: _selectedEvents.length,
                              itemBuilder: (context, index) {
                                final event = _selectedEvents[index];
                                final startDate = DateTime.parse(
                                  event['start_datetime'] ?? '',
                                );
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(event['title'] ?? 'Sin título'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(event['description'] ?? ''),
                                        if (event['location'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lugar: ${event['location']}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteEvent(event['id'] as int),
                                    ),
                                    onTap: () {
                                      _titleController.text =
                                          event['title'] ?? '';
                                      _descriptionController.text =
                                          event['description'] ?? '';
                                      _locationController.text =
                                          event['location'] ?? '';
                                      setState(() {
                                        _selectedDay = startDate;
                                        _editingEventId = event['id'] as int;
                                        _showEventForm = true;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                if (_showEventForm) _buildEventForm(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _titleController.clear();
            _descriptionController.clear();
            _locationController.clear();
            _editingEventId = null;
            _showEventForm = true;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventForm() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingEventId == null ? 'Nuevo Evento' : 'Editar Evento',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showEventForm = false;
                        _editingEventId = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _saveEvent,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
