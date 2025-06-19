import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TareasScreen extends StatefulWidget {
  final int userId;

  const TareasScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _tareas = [];
  String? _token;
  bool _isLoading = true;
  bool _showTaskForm = false;
  DateTime? _selectedDate;
  String _selectedPriority = 'media';
  String _selectedStatus = 'pendiente';
  int? _editingTaskId;

  final List<String> _priorities = ['baja', 'media', 'alta'];
  final List<String> _statuses = ['pendiente', 'completada', 'cancelada'];

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
      await _fetchTasks();
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchTasks() async {
    if (_token == null) {
      _showAuthError();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://appliz-backend-production.up.railway.app/api/tasks'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final processedTasks = List<Map<String, dynamic>>.from(data).map((
          task,
        ) {
          if (task['due_date'] != null && task['due_date'] is String) {
            try {
              // Parsear la fecha y formatearla consistentemente
              task['due_date'] = DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.parse(task['due_date'].split(' ')[0]));
            } catch (e) {
              task['due_date'] = null;
            }
          }
          return task;
        }).toList();

        setState(() {
          _tareas = processedTasks;
        });
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al cargar tareas: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _saveTask() async {
    if (_token == null || _titleController.text.isEmpty) {
      return;
    }

    try {
      final formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;

      final taskData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'due_date': formattedDate,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };

      final response = _editingTaskId == null
          ? await http.post(
              Uri.parse(
                'https://appliz-backend-production.up.railway.app/api/tasks',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: json.encode(taskData),
            )
          : await http.put(
              Uri.parse(
                'https://appliz-backend-production.up.railway.app/api/tasks/$_editingTaskId',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: json.encode(taskData),
            );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea guardada correctamente')),
        );
        _titleController.clear();
        _descriptionController.clear();
        await _fetchTasks();
        setState(() {
          _showTaskForm = false;
          _selectedDate = null;
          _editingTaskId = null;
        });
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al guardar la tarea: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _deleteTask(int taskId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/tasks/$taskId',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
        await _fetchTasks();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al eliminar la tarea: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _completeTask(int taskId) async {
    if (_token == null) return;

    try {
      final response = await http.patch(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/tasks/$taskId/complete',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea marcada como completada')),
        );
        await _fetchTasks();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al completar la tarea: ${response.statusCode}');
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTasks),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  itemCount: _tareas.length,
                  itemBuilder: (context, index) {
                    final tarea = _tareas[index];
                    DateTime? dueDate;

                    if (tarea['due_date'] != null) {
                      try {
                        dueDate = DateTime.parse(tarea['due_date']);
                      } catch (e) {
                        dueDate = null;
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(tarea['title'] ?? 'Sin título'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tarea['description'] != null &&
                                tarea['description'].isNotEmpty)
                              Text(tarea['description']),
                            if (dueDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Vence: ${DateFormat('dd/MM/yyyy').format(dueDate)}',
                                style: TextStyle(
                                  color: dueDate.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    tarea['priority'] ?? 'media',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getPriorityColor(
                                    tarea['priority'],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(tarea['status'] ?? 'pendiente'),
                                  backgroundColor: _getStatusColor(
                                    tarea['status'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tarea['status'] != 'completada')
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () => _completeTask(tarea['id']),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(tarea['id']),
                            ),
                          ],
                        ),
                        onTap: () {
                          _titleController.text = tarea['title'] ?? '';
                          _descriptionController.text =
                              tarea['description'] ?? '';
                          _selectedPriority = tarea['priority'] ?? 'media';
                          _selectedStatus = tarea['status'] ?? 'pendiente';

                          if (tarea['due_date'] != null) {
                            try {
                              _selectedDate = DateTime.parse(tarea['due_date']);
                            } catch (e) {
                              _selectedDate = null;
                            }
                          } else {
                            _selectedDate = null;
                          }

                          setState(() {
                            _editingTaskId = tarea['id'];
                            _showTaskForm = true;
                          });
                        },
                      ),
                    );
                  },
                ),
                if (_showTaskForm) _buildTaskForm(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _titleController.clear();
            _descriptionController.clear();
            _selectedDate = null;
            _selectedPriority = 'media';
            _selectedStatus = 'pendiente';
            _editingTaskId = null;
            _showTaskForm = true;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskForm() {
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
                _editingTaskId == null ? 'Nueva Tarea' : 'Editar Tarea',
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
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de vencimiento (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Seleccionar fecha',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: _priorities
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: _statuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTaskForm = false;
                        _editingTaskId = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _saveTask,
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

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
