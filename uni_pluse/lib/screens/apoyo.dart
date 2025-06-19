import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ApoyoScreen extends StatefulWidget {
  const ApoyoScreen({Key? key}) : super(key: key);

  @override
  State<ApoyoScreen> createState() => _ApoyoScreenState();
}

class _ApoyoScreenState extends State<ApoyoScreen> {
  List<dynamic> jobs = [];
  bool isLoading = true;
  String errorMessage = '';
  String token = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchJobs();
  }

  Future<void> loadUserDataAndFetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token') ?? '';
    final savedUserId = prefs.getInt('user_id') ?? 0;

    if (savedToken.isEmpty || savedUserId == 0) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se encontró sesión activa. Por favor inicia sesión.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      token = savedToken;
      userId = savedUserId;
    });

    await fetchAdzunaJobs();
  }

  Future<void> fetchAdzunaJobs() async {
    final url = 'http://127.0.0.1:5000/api/jobs/adzuna';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          jobs = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Error ${response.statusCode}: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar datos: $e';
        isLoading = false;
      });
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final url = job['link'] ?? '';
            if (url.isNotEmpty) _launchURL(url);
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
                        job['title']?.toString().trim() ?? 'Sin título',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.business, size: 18, color: Colors.blue[300]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job['company']?.toString().trim() ??
                            'Empresa desconocida',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.blue[300]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job['location']?.toString().trim() ??
                            'Ubicación desconocida',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                if (job['salary_min'] != null || job['salary_max'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 18,
                          color: Colors.green[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatSalary(job['salary_min'], job['salary_max']),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSalary(dynamic min, dynamic max) {
    if (min == null && max == null) return 'Salario no especificado';
    if (min == null) return 'Hasta \$${max.toStringAsFixed(0)}';
    if (max == null) return 'Desde \$${min.toStringAsFixed(0)}';
    return '\$${min.toStringAsFixed(0)} - \$${max.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ofertas de Trabajo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.blueGrey[50],
        foregroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAdzunaJobs,
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Buscando ofertas...',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            )
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loadUserDataAndFetchJobs,
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48,
                    color: Colors.blueGrey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron ofertas',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intenta más tarde o ajusta tus filtros',
                    style: TextStyle(color: Colors.blueGrey[400]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchAdzunaJobs,
              color: Colors.blueGrey,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return _buildJobCard(jobs[index]);
                },
              ),
            ),
    );
  }
}
