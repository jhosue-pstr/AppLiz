import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PeriodoScreen extends StatefulWidget {
  final int userId;

  const PeriodoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _PeriodoScreenState createState() => _PeriodoScreenState();
}

class _PeriodoScreenState extends State<PeriodoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  List<Map<String, dynamic>> _periodosCerrados = [];
  String? _token;
  bool _isLoading = true;
  bool _showClosePeriodForm = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        _showAuthError();
        return;
      }

      setState(() {
        _token = token;
      });

      await _checkAdminStatus();
      await _fetchClosedPeriods();
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkAdminStatus() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/user/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isAdmin = data['is_admin'] ?? false;
        });
      } else {
        print('Error en checkAdminStatus: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verificando estado de admin: $e');
    }
  }

  Future<void> _fetchClosedPeriods() async {
    if (_token == null) {
      _showAuthError();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/period/history'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _periodosCerrados = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          setState(() {
            _periodosCerrados = [];
          });
        }
      } else {
        _showError('Error al cargar periodos: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _closePeriod() async {
    if (_token == null ||
        _nameController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      _showError('Por favor complete todos los campos requeridos');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/period/close'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'name': _nameController.text,
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
          'summary': _summaryController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
        _nameController.clear();
        _startDateController.clear();
        _endDateController.clear();
        _summaryController.clear();
        await _fetchClosedPeriods();
        setState(() {
          _showClosePeriodForm = false;
        });
      } else {
        _showError(responseData['error'] ?? 'Error desconocido');
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
        title: const Text('Gestión de Períodos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchClosedPeriods();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _periodosCerrados.isEmpty
          ? const Center(child: Text('No hay períodos cerrados'))
          : Stack(
              children: [
                ListView.builder(
                  itemCount: _periodosCerrados.length,
                  itemBuilder: (context, index) {
                    final periodo = _periodosCerrados[index];
                    print('Periodo $index: ${periodo.toString()}'); // Debug

                    final closedAt = periodo['closed_at'] != null
                        ? DateTime.tryParse(periodo['closed_at'])
                        : null;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          periodo['period_name']?.toString() ??
                              'Periodo sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Del ${periodo['start_date']} al ${periodo['end_date']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (periodo['description']?.toString().isNotEmpty ??
                                false)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(periodo['description']),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              'Cerrado por: ${periodo['user_name'] ?? 'Sistema'}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (closedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Fecha cierre: ${DateFormat('dd/MM/yyyy HH:mm').format(closedAt)}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_showClosePeriodForm) _buildClosePeriodForm(),
              ],
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => setState(() => _showClosePeriodForm = true),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildClosePeriodForm() {
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
              const Text(
                'Cerrar Período',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Período*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio*',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context, _startDateController),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de fin*',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context, _endDateController),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _summaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Resumen (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showClosePeriodForm = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _closePeriod,
                    child: const Text('Cerrar Período'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '* Campos obligatorios',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
