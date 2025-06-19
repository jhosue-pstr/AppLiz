import 'package:flutter/material.dart';

class PagosScreen extends StatelessWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pagos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              'Opciones de Pago',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Pago Único
            _buildPricingCard(
              title: "Pago Único",
              price: "\$9.99",
              icon: Icons.payment,
              color: Colors.blueAccent,
              isPopular: false,
            ),
            const SizedBox(height: 15),

            // Tarjeta de Suscripción Mensual
            _buildPricingCard(
              title: "Suscripción Mensual",
              price: "\$1.99/mes",
              icon: Icons.calendar_today,
              color: Colors.purple,
              isPopular: true,
            ),
            const SizedBox(height: 15),

            // Tarjeta de Suscripción Anual
            _buildPricingCard(
              title: "Suscripción Anual",
              price: "\$14.99/año",
              icon: Icons.star,
              color: Colors.orange,
              isPopular: false,
            ),
            const SizedBox(height: 30),

            // Sección "Próximamente"
            const Divider(),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    "🚀 Próximamente",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Más métodos de pago y promociones exclusivas",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para las tarjetas de precios
Widget _buildPricingCard({
  required String title,
  required String price,
  required IconData icon,
  required Color color,
  required bool isPopular,
}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icono decorativo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),

          // Texto del plan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Badge "Popular" (opcional)
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Recomendado",
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
        ],
      ),
    ),
  );
}
