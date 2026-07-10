import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/route.dart';
import 'BottomBar.dart'; // Import aggiornato con il nuovo nome del file

class NewCost extends StatefulWidget {
  const NewCost({Key? key}) : super(key: key);

  @override
  State<NewCost> createState() => _NewCostState();
}

class _NewCostState extends State<NewCost> {
  // Variabili per i menu a tendina
  String? _statoSelezionato;
  String? _metodoPagamento;
  String _valutaSelezionata = 'EUR';

  // Variabili per gli errori in tempo reale
  String? _erroreData;
  String? _erroreOra;

  // --- LOGICA CONTROLLO DATA ---
  void _validaData(String valore) {
    if (valore.isEmpty) {
      setState(() => _erroreData = null);
      return;
    }

    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(valore)) {
      setState(() => _erroreData = 'Data non valida');
      return;
    }

    final parti = valore.split('/');
    final giorno = int.tryParse(parti[0]) ?? 0;
    final mese = int.tryParse(parti[1]) ?? 0;
    final anno = int.tryParse(parti[2]) ?? 0;

    if (mese < 1 || mese > 12) {
      setState(() => _erroreData = 'Data non valida');
      return;
    }

    int maxGiorni = 31;
    if (mese == 4 || mese == 6 || mese == 9 || mese == 11) {
      maxGiorni = 30;
    } else if (mese == 2) {
      final bisestile = (anno % 4 == 0 && anno % 100 != 0) || (anno % 400 == 0);
      maxGiorni = bisestile ? 29 : 28;
    }

    if (giorno < 1 || giorno > maxGiorni) {
      setState(() => _erroreData = 'Data non valida');
      return;
    }

    setState(() => _erroreData = null);
  }

  // --- LOGICA CONTROLLO ORA ---
  void _validaOra(String valore) {
    if (valore.isEmpty) {
      setState(() => _erroreOra = null);
      return;
    }

    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(valore)) {
      setState(() => _erroreOra = 'Ora non valida');
      return;
    }

    final parti = valore.split(':');
    final ore = int.tryParse(parti[0]) ?? -1;
    final minuti = int.tryParse(parti[1]) ?? -1;

    if (ore < 0 || ore > 23 || minuti < 0 || minuti > 59) {
      setState(() => _erroreOra = 'Ora non valida');
      return;
    }

    setState(() => _erroreOra = null);
  }

  @override
  Widget build(BuildContext context) {
    // 1. SFONDO DI TUTTA LA PAGINA GIALLO
    return Scaffold(
      backgroundColor: Colors.amber,

      // 2. NUOVA BARRA SUPERIORE INTEGRATA
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            // Logica per tornare indietro
          },
        ),
        
        centerTitle: true,
        title: const Text(
          'NUOVA SPESA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              // Logica menu laterale
            },
          ),
        ],
      ),

      // 3. CORPO CENTRALE ADATTATO A TUTTO SCHERMO
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. STATO
              Row(
                children: [
                  const Text('STATO: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statoSelezionato,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                      hint: const Text('. . .'),
                      items: [
                        DropdownMenuItem(
                          value: 'Da pagare',
                          child: Row(children: const [Icon(Icons.circle, color: Colors.red, size: 14), SizedBox(width: 8), Text('Da pagare')]),
                        ),
                        DropdownMenuItem(
                          value: 'Pagata',
                          child: Row(children: const [Icon(Icons.circle, color: Colors.green, size: 14), SizedBox(width: 8), Text('Pagata')]),
                        ),
                      ],
                      onChanged: (valore) {
                        setState(() => _statoSelezionato = valore);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 2. DATA (GG/MM/AAAA)
              TextField(
                onChanged: _validaData,
                decoration: InputDecoration(
                  hintText: 'GG/MM/AAAA',
                  errorText: _erroreData,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 15),

              // 3. ORA (HH:MM)
              TextField(
                onChanged: _validaOra,
                decoration: InputDecoration(
                  hintText: 'HH:MM',
                  errorText: _erroreOra,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // 4. TITOLO
              const Text('TITOLO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              const TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // 5. DESCRIZIONE
              const Text('DESCRIZIONE:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // 6. METODO PAGAMENTO
              Row(
                children: [
                  const Text('METODO\nPAGAMENTO: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _metodoPagamento,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                      hint: const Text('. . .'),
                      items: const [
                        DropdownMenuItem(value: 'Contanti', child: Text('Contanti')),
                        DropdownMenuItem(value: 'Carta di credito', child: Text('Carta di credito')),
                        DropdownMenuItem(value: 'Carta di debito', child: Text('Carta di debito')),
                      ],
                      onChanged: (valore) {
                        setState(() => _metodoPagamento = valore);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 7. COSTO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text('COSTO ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: DropdownButton<String>(
                      value: _valutaSelezionata,
                      underline: const SizedBox(),
                      items: ['EUR', 'USD', 'GBP', 'JPY', 'CHF']
                          .map((valuta) => DropdownMenuItem(
                                value: valuta,
                                child: Text(valuta, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (valore) {
                        if (valore != null) {
                          setState(() => _valutaSelezionata = valore);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 8. BOTTONE CONFERMA
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Logica di salvataggio
                    Navigator.pushReplacementNamed(context, AppRoutes.riepilogoViaggio);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text('CONFERMA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // 4. RICHIAMO DELLA TUA BOTTOM BAR
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}