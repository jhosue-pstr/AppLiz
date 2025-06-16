import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> _entries = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _patterns = {};

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
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchHistory();
    await _fetchStats();
    await _fetchPatterns();
  }

  Future<void> _fetchHistory() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/diary/history?user_id=${widget.userId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _entries = json.decode(response.body);
      });
    }
  }

  Future<void> _fetchStats() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/diary/stats?user_id=${widget.userId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _stats = json.decode(response.body);
      });
    }
  }

  Future<void> _fetchPatterns() async {
    final response = await http.get(
      Uri.parse(
        'http://127.0.0.1:5000/diary/patterns?user_id=${widget.userId}',
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        _patterns = json.decode(response.body);
      });
    }
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
        body: TabBarView(
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
    if (_entries.isEmpty)
      return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final emotion = _emotions.firstWhere(
          (e) => e['value'] == entry['emotion'],
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
                if (entry['content'] != null) Text(entry['content']),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEntry(entry['id']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_stats.isEmpty || _patterns.isEmpty)
      return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Resumen Semanal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(height: 200, child: _buildWeeklyChart()),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Emoción más frecuente: ${_patterns['dominant_emotion'] ?? 'No hay datos'}',
                  ),
                  Text(
                    'Día más común: ${_patterns['most_frequent_day'] ?? 'No hay datos'}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final weeklyData = _stats['weekly_summary'] ?? [];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = weeklyData[groupIndex];
              final emotion = _emotions.firstWhere(
                (e) => e['value'] == entry['emotion'],
              );
              return BarTooltipItem(
                '${entry['emotion']}\n${entry['count']}',
                TextStyle(color: emotion['color'], fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= weeklyData.length) return const SizedBox();
                final entry = weeklyData[value.toInt()];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(entry['day'].substring(0, 3)),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final emotion = _emotions.firstWhere(
            (e) => e['value'] == data['emotion'],
          );

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['count'].toDouble(),
                color: emotion['color'],
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_selectedEmotion == null) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/diary/entries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': widget.userId,
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
    }
  }

  Future<void> _deleteEntry(int entryId) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/diary/entries/$entryId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entrada eliminada')));
      _loadData();
    }
  }
}
