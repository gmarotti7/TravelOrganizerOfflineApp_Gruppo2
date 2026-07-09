import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BottomBar.dart'; // La tua barra di navigazione inferiore

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  // Controller per leggere e scrivere nei campi di testo
  final TextEditingController _tuaValutaController = TextEditingController();
  final TextEditingController _valutaLocaleController = TextEditingController();

  // Valute selezionate nei menu a tendina
  String _tuaValuta = 'EUR';
  String _valutaLocale = 'USD';

  // Lista delle valute disponibili
  final List<String> _valuteDisponibili = ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];

  // Metodo che esegue la logica di conversione
  void _eseguiConversione() {
    String testoTuaValuta = _tuaValutaController.text.trim();
    String testoValutaLocale = _valutaLocaleController.text.trim();

    // 1. Controllo: Entrambi i campi sono pieni
    if (testoTuaValuta.isNotEmpty && testoValutaLocale.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: Inserisci il valore solo in una casella. Lascia vuota quella da calcolare!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Controllo: Entrambi i campi sono vuoti
    if (testoTuaValuta.isEmpty && testoValutaLocale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci un importo da convertire.'),
        ),
      );
      return;
    }

    // Tassi di cambio fittizi (rispetto all'Euro) da spostare poi nel tuo Controller MVC
    Map<String, double> tassiDiCambio = {
      'EUR': 1.0,
      'USD': 1.10,
      'GBP': 0.85,
      'JPY': 160.0,
      'CHF': 0.95,
    };

    // 3. Calcolo: Da "Tua Valuta" a "Valuta Locale"
    if (testoTuaValuta.isNotEmpty) {
      double? importoIniziale = double.tryParse(testoTuaValuta.replaceAll(',', '.'));
      if (importoIniziale != null) {
        // Passo per l'Euro come base per fare la conversione incrociata
        double inEuro = importoIniziale / tassiDiCambio[_tuaValuta]!;
        double risultato = inEuro * tassiDiCambio[_valutaLocale]!;
        _valutaLocaleController.text = risultato.toStringAsFixed(2);
      }
    } 
    // 4. Calcolo Inverso: Da "Valuta Locale" a "Tua Valuta"
    else if (testoValutaLocale.isNotEmpty) {
      double? importoIniziale = double.tryParse(testoValutaLocale.replaceAll(',', '.'));
      if (importoIniziale != null) {
        double inEuro = importoIniziale / tassiDiCambio[_valutaLocale]!;
        double risultato = inEuro * tassiDiCambio[_tuaValuta]!;
        _tuaValutaController.text = risultato.toStringAsFixed(2);
      }
    }
  }

  // Pulisce la memoria dei controller quando la pagina viene chiusa
  @override
  void dispose() {
    _tuaValutaController.dispose();
    _valutaLocaleController.dispose();
    super.dispose();
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'CONVERTITORE',
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
              
              // SEZIONE 1: LA TUA VALUTA
              const Text(
                'LA TUA VALUTA',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              _buildInputRow(
                valutaSelezionata: _tuaValuta,
                controller: _tuaValutaController,
                onValutaChanged: (nuovaValuta) {
                  setState(() => _tuaValuta = nuovaValuta!);
                },
              ),

              const SizedBox(height: 50),

              // SEZIONE 2: VALUTA LOCALE
              const Text(
                'VALUTA LOCALE',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              _buildInputRow(
                valutaSelezionata: _valutaLocale,
                controller: _valutaLocaleController,
                onValutaChanged: (nuovaValuta) {
                  setState(() => _valutaLocale = nuovaValuta!);
                },
              ),

              const SizedBox(height: 60),

              // BOTTONE CONVERTI CON ICONA CIRCOLARE
              Center(
                child: GestureDetector(
                  onTap: _eseguiConversione, // Richiama la funzione logica creata sopra
                  child: Column(
                    children: const [
                      Icon(
                        Icons.sync, // Icona frecce circolari
                        size: 80,
                        color: Colors.black,
                      ),
                      Text(
                        'CONVERTI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // --- BARRA DI NAVIGAZIONE INFERIORE ---
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // --- WIDGET DI SUPPORTO PER RICREARE LO STILE DEL BOZZETTO ---
  Widget _buildInputRow({
    required String valutaSelezionata,
    required TextEditingController controller,
    required ValueChanged<String?> onValutaChanged,
  }) {
    return Row(
      children: [
        // Menu a tendina nero con testo bianco
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: DropdownButton<String>(
            dropdownColor: Colors.black,
            value: valutaSelezionata,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            underline: const SizedBox(), // Rimuove la linea di base predefinita
            items: _valuteDisponibili.map((String valuta) {
              return DropdownMenuItem<String>(
                value: valuta,
                child: Text(valuta),
              );
            }).toList(),
            onChanged: onValutaChanged,
          ),
        ),
        
        const SizedBox(width: 15),
        
        // Casella di testo nera con testo bianco
        Expanded(
          child: Container(
            color: Colors.black,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                hintText: 'TEXT',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}