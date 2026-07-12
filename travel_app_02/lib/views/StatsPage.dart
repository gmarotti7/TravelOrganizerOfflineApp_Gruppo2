import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart';
import 'dart:math'; // Necessario per calcolare gli angoli del grafico a torta
import 'BottomBar.dart';
import 'package:travel_app_02/sessione.dart';
import 'package:travel_app_02/controllers/stats_controller.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsController _statsController = StatsController();
  late Future<StatisticheUtente> _futureStatistiche;

  // Colori usati in modo coerente tra legenda e grafico a torta.
  static const List<Color> _paletteDestinazioni = [
    Color(0xFF1565C0), // blu
    Color(0xFF2E7D32), // verde
    Color(0xFFEF6C00), // arancione
    Color(0xFF6A1B9A), // viola
    Color(0xFFC62828), // rosso
    Color(0xFF9E9E9E), // grigio (usato per "Altro")
  ];

  static const List<Color> _paletteCategorie = [
    Color(0xFFEF6C00),
    Color(0xFF283593),
    Color(0xFFC62828),
    Color(0xFF6A1B9A),
    Color(0xFF00695C),
    Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    _caricaStatistiche();
  }

  void _caricaStatistiche() {
    final int idUtente = Sessione.idUtenteAttuale ?? 1;
    _futureStatistiche = _statsController.calcolaStatistiche(idUtente);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Forziamo il ritorno alla Home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.amber, // Sfondo giallo full-screen

        // --- BARRA SUPERIORE ---
        appBar: AppBar(
          backgroundColor: Colors.amber,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () {
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
        body: FutureBuilder<StatisticheUtente>(
          future: _futureStatistiche,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Errore nel calcolo delle statistiche: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            final stats = snapshot.data!;

            if (!stats.haViaggi) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Aggiungi il tuo primo viaggio per iniziare a vedere le statistiche!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. RISPETTO DEL BUDGET (Grafico Circolare)
                    _buildSectionTitle('RISPETTO DEL BUDGET'),
                    const SizedBox(height: 15),
                    _buildBudgetSection(stats),

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
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                          Text(
                            '${stats.costoMedioGiornaliero.toStringAsFixed(2)} ${Sessione.valutaAttuale} / giorno',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 3. DESTINAZIONI (Grafico a Torta)
                    _buildSectionTitle('DESTINAZIONI PREFERITE'),
                    const SizedBox(height: 20),
                    _buildDestinazioniSection(stats),

                    const SizedBox(height: 40),

                    // 4. SPESE PER CATEGORIA (Grafico a Barre orizzontali)
                    _buildSectionTitle('SPESE PER CATEGORIA'),
                    const SizedBox(height: 20),
                    _buildSpeseCategoriaSection(stats),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),

        // --- BOTTOM BAR ---
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  // --- SEZIONE BUDGET ---
  Widget _buildBudgetSection(StatisticheUtente stats) {
    if (stats.percentualeBudget == null) {
      return const Text(
        'Nessun viaggio con un budget previsto impostato.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      );
    }

    final double percentuale = stats.percentualeBudget!;
    final bool sforato = percentuale > 1.0;
    final double valoreIndicatore = percentuale.clamp(0.0, 1.0);
    final Color colore = sforato
        ? Colors.red.shade700
        : (percentuale > 0.9 ? Colors.orange.shade800 : Colors.green.shade800);

    final String messaggio = sforato
        ? 'Hai superato il budget previsto di ${(percentuale * 100 - 100).toStringAsFixed(0)}%.'
        : (percentuale > 0.9
            ? 'Ti stai avvicinando al budget previsto, occhio alle spese!'
            : 'Sei in linea con il budget previsto per i tuoi viaggi.');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: valoreIndicatore,
                strokeWidth: 12,
                backgroundColor: Colors.black12,
                color: colore,
              ),
            ),
            Text(
              '${(percentuale * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Text(
            messaggio,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        )
      ],
    );
  }

  // --- SEZIONE DESTINAZIONI ---
  Widget _buildDestinazioniSection(StatisticheUtente stats) {
    if (stats.destinazioniPreferite.isEmpty) {
      return const Text(
        'Nessun dato sulle destinazioni disponibile.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      );
    }

    // Mostriamo al massimo le 5 destinazioni più frequenti, raggruppando le
    // restanti in "Altro" per non affollare il grafico.
    final tutte = stats.destinazioniPreferite;
    final top = tutte.take(5).toList();
    final int totale = stats.numeroViaggiTotali;
    final int coperti = top.fold(0, (tot, e) => tot + e.value);
    if (tutte.length > top.length && (totale - coperti) > 0) {
      top.add(MapEntry('Altro', totale - coperti));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _PieChartPainter(
              valori: top.map((e) => e.value.toDouble()).toList(),
              totale: totale.toDouble(),
              colori: _paletteDestinazioni,
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < top.length; i++) ...[
                _buildLegendItem(
                  top[i].key,
                  '${((top[i].value / totale) * 100).toStringAsFixed(0)}%',
                  _paletteDestinazioni[i % _paletteDestinazioni.length],
                ),
                if (i != top.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        )
      ],
    );
  }

  // --- SEZIONE SPESE PER CATEGORIA ---
  Widget _buildSpeseCategoriaSection(StatisticheUtente stats) {
    if (!stats.haSpese || stats.spesePerCategoria.isEmpty) {
      return const Text(
        'Nessuna spesa registrata ancora.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      );
    }

    final double maxValore = stats.spesePerCategoria.first.value;

    return Column(
      children: [
        for (int i = 0; i < stats.spesePerCategoria.length; i++) ...[
          _buildBarRow(
            stats.spesePerCategoria[i].key,
            stats.spesePerCategoria[i].value,
            maxValore,
            _paletteCategorie[i % _paletteCategorie.length],
          ),
          if (i != stats.spesePerCategoria.length - 1) const SizedBox(height: 15),
        ],
      ],
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
        Expanded(
          child: Text(
            '$nome: $percentuale',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBarRow(String etichetta, double valore, double maxValore, Color colore) {
    // Calcola la percentuale di riempimento della barra (da 0.0 a 1.0)
    final double proporzione = maxValore > 0 ? (valore / maxValore) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etichetta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${valore.toStringAsFixed(2)} ${Sessione.valutaAttuale}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        Stack(
          children: [
            Container(height: 20, width: double.infinity, color: Colors.black12),
            FractionallySizedBox(
              widthFactor: proporzione.clamp(0.0, 1.0),
              child: Container(height: 20, color: colore),
            ),
          ],
        ),
      ],
    );
  }
}

// --- CLASSE PER DISEGNARE IL GRAFICO A TORTA NATIVAMENTE (dati reali) ---
class _PieChartPainter extends CustomPainter {
  final List<double> valori; // frequenza di ogni fetta
  final double totale; // totale su cui calcolare le percentuali (può includere "Altro")
  final List<Color> colori;

  _PieChartPainter({required this.valori, required this.totale, required this.colori});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    if (totale <= 0) return;

    double angoloIniziale = -pi / 2;
    for (int i = 0; i < valori.length; i++) {
      final double angoloFetta = (valori[i] / totale) * 2 * pi;
      paint.color = colori[i % colori.length];
      canvas.drawArc(rect, angoloIniziale, angoloFetta, true, paint);
      angoloIniziale += angoloFetta;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.valori != valori || oldDelegate.totale != totale;
}