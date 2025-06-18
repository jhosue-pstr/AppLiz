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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas de Trabajo')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      (job['title'] != null &&
                              job['title'].toString().trim().isNotEmpty)
                          ? job['title']
                          : 'Sin título',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (job['company'] != null &&
                                  job['company'].toString().trim().isNotEmpty)
                              ? job['company']
                              : 'Empresa desconocida',
                          style: TextStyle(color: textColor),
                        ),
                        Text(
                          (job['location'] != null &&
                                  job['location'].toString().trim().isNotEmpty)
                              ? job['location']
                              : 'Ubicación desconocida',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      final url = job['link'] ?? '';
                      if (url.isNotEmpty) {
                        _launchURL(url);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
