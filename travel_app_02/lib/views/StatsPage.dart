import 'package:flutter/material.dart';
import 'dart:math'; // Necessario per calcolare gli angoli del grafico a torta
import 'BottomBar.dart'; // La tua barra di navigazione

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // Sfondo giallo full-screen
      
      // --- BARRA SUPERIORE ---
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            // Torna alla pagina precedente
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'STATISTICHE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      
      // --- CORPO CENTRALE ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. RISPETTO DEL BUDGET (Grafico Circolare)
              _buildSectionTitle('RISPETTO DEL BUDGET'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 0.85, // Valore da 0.0 a 1.0 (85%)
                          strokeWidth: 12,
                          backgroundColor: Colors.black12,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const Text(
                        '85%',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  const Expanded(
                    child: Text(
                      'Sei perfettamente in linea con le spese previste!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 40),

              // 2. COSTO MEDIO GIORNALIERO (Card testuale)
              _buildSectionTitle('COSTO MEDIO GIORNALIERO'),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.white, size: 30),
                    Text(
                      '45.50 EUR / giorno',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. DESTINAZIONI (Grafico a Torta personalizzato)
              _buildSectionTitle('DESTINAZIONI PREFERITE'),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Il disegno della torta
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _PieChartPainter(),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // La Legenda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Mare', '50%', Colors.blue.shade700),
                        const SizedBox(height: 10),
                        _buildLegendItem('Montagna', '30%', Colors.green.shade700),
                        const SizedBox(height: 10),
                        _buildLegendItem('Città', '20%', Colors.grey.shade800),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 40),

              // 4. SPESE PER CATEGORIA (Grafico a Barre orizzontali)
              _buildSectionTitle('SPESE PER CATEGORIA'),
              const SizedBox(height: 20),
              // Dati fittizi per l'esempio (Max 300 EUR per calcolare le proporzioni)
              _buildBarRow('Cibo & Bevande', 250, 300, Colors.orange.shade800),
              const SizedBox(height: 15),
              _buildBarRow('Alloggio', 300, 300, Colors.indigo.shade800),
              const SizedBox(height: 15),
              _buildBarRow('Trasporti', 120, 300, Colors.red.shade800),
              const SizedBox(height: 15),
              _buildBarRow('Svago', 80, 300, Colors.purple.shade800),

              const SizedBox(height: 40), // Spazio finale prima della bottom bar
            ],
          ),
        ),
      ),
      
      // --- BOTTOM BAR ---
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // --- WIDGET DI SUPPORTO PER TENERE IL CODICE PULITO ---
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildLegendItem(String nome, String percentuale, Color colore) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: colore),
        const SizedBox(width: 10),
        Text(
          '$nome: $percentuale',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildBarRow(String etichetta, double valore, double maxValore, Color colore) {
    // Calcola la percentuale di riempimento della barra (da 0.0 a 1.0)
    double proporzione = valore / maxValore;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etichetta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${valore.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        Stack(
          children: [
            // Sfondo della barra (nero vuoto)
            Container(height: 20, width: double.infinity, color: Colors.black12),
            // Riempimento della barra
            FractionallySizedBox(
              widthFactor: proporzione,
              child: Container(height: 20, color: colore),
            ),
          ],
        ),
      ],
    );
  }
}

// --- CLASSE PER DISEGNARE IL GRAFICO A TORTA NATIVAMENTE ---
class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    // Angoli in radianti. Un cerchio completo è 2 * pi (circa 6.28)
    // Mare: 50% = 0.5 * 2 * pi
    paint.color = Colors.blue.shade700;
    canvas.drawArc(rect, -pi / 2, pi, true, paint); // Parte dall'alto (-pi/2)

    // Montagna: 30% = 0.3 * 2 * pi
    paint.color = Colors.green.shade700;
    canvas.drawArc(rect, -pi / 2 + pi, 2 * pi * 0.3, true, paint); 

    // Città: 20% = 0.2 * 2 * pi
    paint.color = Colors.grey.shade800;
    canvas.drawArc(rect, -pi / 2 + pi + (2 * pi * 0.3), 2 * pi * 0.2, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}