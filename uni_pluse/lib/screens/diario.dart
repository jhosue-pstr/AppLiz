import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DiarioScreen extends StatefulWidget {
  final int userId;

  const DiarioScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DiarioScreenState createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  String? _selectedEmotion;
  int _intensity = 3;
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _patterns = {};
  String? _token;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _emotions = [
    {'value': 'feliz', 'emoji': '😊', 'color': Colors.green},
    {'value': 'triste', 'emoji': '😢', 'color': Colors.blue},
    {'value': 'enojado', 'emoji': '😡', 'color': Colors.red},
    {'value': 'ansioso', 'emoji': '😰', 'color': Colors.orange},
    {'value': 'neutral', 'emoji': '😐', 'color': Colors.grey},
    {'value': 'motivado', 'emoji': '💪', 'color': Colors.purple},
    {'value': 'agotado', 'emoji': '😴', 'color': Colors.brown},
  ];

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) => _loadData());
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_fetchHistory(), _fetchStats(), _fetchPatterns()]);
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchHistory() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:5000/api/emotion/entries?days=30&page=1&per_page=20',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> entries = responseData['data'];
          final List<Map<String, dynamic>> parsedEntries = [];

          for (var entry in entries) {
            if (entry is Map<String, dynamic>) {
              parsedEntries.add({
                'id': entry['id']?.toInt() ?? 0,
                'emotion': entry['emotion']?.toString() ?? '',
                'intensity': entry['intensity']?.toInt() ?? 0,
                'content': entry['content']?.toString() ?? '',
                'formatted_date': entry['formatted_date']?.toString() ?? '',
              });
            }
          }

          if (mounted) {
            setState(() => _entries = parsedEntries);
          }
        }
      } else if (response.statusCode == 401) {
        _showAuthError();
      }
    } catch (e) {
      _showError('Error al cargar historial');
      debugPrint('Error detallado: $e');
    }
  }

  Future<void> _fetchStats() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/emotion/stats'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() => _stats = Map<String, dynamic>.from(data));
        }
      } else if (response.statusCode == 401) {
        _showAuthError();
      }
    } catch (e) {
      _showError('Error al cargar estadísticas');
      debugPrint('Error en stats: $e');
    }
  }

  Future<void> _fetchPatterns() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/emotion/patterns'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _patterns = Map<String, dynamic>.from(data['data'] ?? {});
            // Debug para verificar los datos recibidos
            debugPrint('Patrones recibidos: ${_patterns.toString()}');
          });
        }
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        debugPrint('Error en patterns: ${response.body}');
      }
    } catch (e) {
      _showError('Error al cargar patrones');
      debugPrint('Error en patterns: $e');
    }
  }

  void _showAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión expirada, por favor inicia sesión nuevamente'),
      ),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diario'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: 'Registrar'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
              Tab(icon: Icon(Icons.insights), text: 'Estadísticas'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildEmotionRegister(),
                  _buildHistoryTab(),
                  _buildStatsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildEmotionRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('¿Cómo te sientes hoy?', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emotions
                .map((emotion) => _buildEmotionChoice(emotion))
                .toList(),
          ),
          const SizedBox(height: 30),
          if (_selectedEmotion != null) ...[
            Text(
              'Intensidad: $_intensity',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) => setState(() => _intensity = value.round()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales',
                border: OutlineInputBorder(),
                hintText: '¿Qué ha influido en tu estado de ánimo hoy?',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Guardar Entrada'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionChoice(Map<String, dynamic> emotion) {
    return ChoiceChip(
      label: Text('${emotion['emoji']} ${emotion['value']}'),
      selected: _selectedEmotion == emotion['value'],
      onSelected: (selected) =>
          setState(() => _selectedEmotion = selected ? emotion['value'] : null),
      backgroundColor: emotion['color'].withOpacity(0.2),
      selectedColor: emotion['color'],
      labelStyle: TextStyle(
        color: _selectedEmotion == emotion['value']
            ? Colors.white
            : Colors.black,
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No hay entradas registradas'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Recargar datos'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final emotion = _emotions.firstWhere(
            (e) => e['value'] == entry['emotion'],
            orElse: () => {'emoji': '❓', 'color': Colors.grey},
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: emotion['color'].withOpacity(0.2),
                child: Text(
                  emotion['emoji'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(
                '${entry['emotion']} (Intensidad: ${entry['intensity']}/5)',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry['formatted_date']),
                  if (entry['content'] != null && entry['content'].isNotEmpty)
                    Text(entry['content']),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEntry(entry['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No hay datos estadísticos disponibles'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_stats['weekly_summary'] != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Resumen Semanal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(height: 200, child: _buildWeeklyChart()),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detección de Patrones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Emoción más frecuente: ${_patterns['dominant_emotion']?.toString() ?? 'No disponible'}',
                    ),
                    Text(
                      'Día más común: ${_patterns['most_frequent_day']?.toString() ?? 'No disponible'}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    try {
      final weeklyData = (_stats['weekly_summary'] as List?) ?? [];
      if (weeklyData.isEmpty) {
        return const Center(child: Text('No hay datos para mostrar'));
      }

      return BarChart(
        BarChartData(
          barGroups: weeklyData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value as Map<String, dynamic>;
            final emotion = _emotions.firstWhere(
              (e) => e['value'] == data['emotion']?.toString(),
              orElse: () => {'color': Colors.grey},
            );

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (data['count'] as num?)?.toDouble() ?? 0,
                  color: emotion['color'] as Color,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= weeklyData.length)
                    return const SizedBox();
                  final day =
                      (weeklyData[value.toInt()] as Map)['day']?.toString() ??
                      '';
                  return Text(day.isNotEmpty ? day.substring(0, 3) : '');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error al construir gráfico: $e');
      return Center(child: Text('Error: ${e.toString()}'));
    }
  }

  Future<void> _saveEntry() async {
    if (_selectedEmotion == null || _token == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/emotion/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'emotion': _selectedEmotion,
          'intensity': _intensity,
          'content': _noteController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada guardada correctamente')),
        );
        _noteController.clear();
        _loadData();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al guardar la entrada: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _deleteEntry(int entryId) async {
    if (_token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:5000/api/emotion/entries/$entryId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entrada eliminada')));
        _loadData();
      } else if (response.statusCode == 401) {
        _showAuthError();
      } else {
        _showError('Error al eliminar la entrada: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }
}
