// lib/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart';
import 'BottomBar.dart';
import 'add_trip.dart'; // AGGIUNTO: Import della pagina per creare il viaggio
import 'package:travel_app_02/models/viaggio.dart'; // AGGIUNTO: Import del modello del tuo collega
import 'package:travel_app_02/views/Add_trip.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller per la barra di ricerca
  final _searchController = TextEditingController();
  
  // Data selezionata tramite il calendario (null se nessun filtro data è attivo)
  DateTime? _selectedDate;

  // Lista simulata di viaggi (Database temporaneo)
  final List<Viaggio> _tuttiIViaggi = [
    Viaggio(titolo: 'Vacanze Estive', luogo: 'Barcellona', dataInizio: DateTime(2026, 08, 15), id: '0001', dataFine: DateTime(2026, 08, 22), budgetPrevisto: 500),
    Viaggio(titolo: 'Capodanno a Londra', luogo: 'Londra', dataInizio: DateTime(2027, 01, 01), id: '002', dataFine: DateTime(2027, 01, 08), budgetPrevisto: 700),
    Viaggio(titolo: 'Laurea Amo', luogo: 'Salerno', dataInizio: DateTime(2026, 03, 10), id: '0003', dataFine: DateTime(2026, 03, 18), budgetPrevisto: 400),
    Viaggio(titolo: 'Weekend Romantico', luogo: 'Parigi', dataInizio: DateTime(2025, 12, 25), id: '0004', dataFine: DateTime(2025, 12, 29), budgetPrevisto: 500),
  ];

  // Lista che contiene i viaggi filtrati da mostrare sulla UI
  List<Viaggio> _viaggiFiltrati = [];

  @override
  void initState() {
    super.initState();
    _viaggiFiltrati = _tuttiIViaggi; // All'inizio mostra tutti i viaggi
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Funzione unica che unisce il filtro testuale e il filtro data
  void _applicaFiltri() {
    String query = _searchController.text.toLowerCase().trim();
    DateTime oggi = DateTime.now();

    setState(() {
      _viaggiFiltrati = _tuttiIViaggi.where((viaggio) {
        // CORRETTO: Sostituito viaggio.data con viaggio.dataInizio
        String statoViaggio = viaggio.dataInizio.isAfter(oggi) ? 'da fare' : 'passato';

        // 1. Controllo Filtro Testuale
        bool matchTesto = viaggio.luogo.toLowerCase().contains(query) || 
                          statoViaggio.contains(query) ||
                          viaggio.titolo.toLowerCase().contains(query);

        // 2. Controllo Filtro Data
        bool matchData = true;
        if (_selectedDate != null) {
          matchData = viaggio.dataInizio.year == _selectedDate!.year &&
                      viaggio.dataInizio.month == _selectedDate!.month &&
                      viaggio.dataInizio.day == _selectedDate!.day;
        }

        return matchTesto && matchData;
      }).toList();
    });
  }

  // Funzione per aprire il DatePicker nativo di Flutter
  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF121212),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _applicaFiltri();
    }
  }

  // Funzione per resettare il filtro della data
  void _rimuoviFiltroData() {
    setState(() {
      _selectedDate = null;
    });
    _applicaFiltri();
  }

  @override
  Widget build(BuildContext context) {
    DateTime oggi = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1), // Giallo ocra
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. TITOLO IN ALTO AL CENTRO
              const Center(
                child: Text(
                  'I TUOI VIAGGI',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. BARRA DI RICERCA CON LENTE E CALENDARIO
              TextField(
                controller: _searchController,
                onChanged: (value) => _applicaFiltri(),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'LUOGO, DATA, STATO',
                  hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_month,
                      color: _selectedDate == null ? Colors.black : Colors.red,
                    ),
                    onPressed: () {
                      if (_selectedDate == null) {
                        _selezionaData(context);
                      } else {
                        _rimuoviFiltroData();
                      }
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.black, width: 2.5),
                  ),
                ),
              ),

              // Indicatore filtro data attivo
              if (_selectedDate != null) ...[
                const SizedBox(height: 5),
                Text(
                  "Filtro data attivo: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 25),

              // 3. SEZIONE LISTA VIAGGI
              Expanded(
                child: _viaggiFiltrati.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Nessun viaggio trovato",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 15),
                            _buildBottoneNuovoViaggio(),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _viaggiFiltrati.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _viaggiFiltrati.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: _buildBottoneNuovoViaggio(),
                            );
                          }

                          final viaggio = _viaggiFiltrati[index];
                          bool isFuturo = viaggio.dataInizio.isAfter(oggi);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: InkWell(
                              onTap: () {
                                debugPrint("Cliccato sul viaggio: ${viaggio.titolo}");
                              },
                              borderRadius: BorderRadius.circular(5),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: isFuturo ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black, width: 1),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        viaggio.titolo,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildBottoneNuovoViaggio() {
    return InkWell(
      onTap: () async {
        final risultato = await Navigator.pushNamed(context, AppRoutes.addTrip);

        if (risultato != null && risultato is Map<String, dynamic>) {
          setState(() {
            _tuttiIViaggi.add(
              // CORRETTO: Inserimento dinamico con i nuovi parametri del modello
              Viaggio(
                titolo: risultato['titolo'],
                luogo: risultato['luogo'],
                dataInizio: risultato['data'],
                dataFine: risultato['data'], // Per ora mettiamo la stessa data
                id: DateTime.now().millisecondsSinceEpoch.toString(), // ID univoco fittizio
                budgetPrevisto: 0.0, // Budget di default in attesa del collegamento
              ),
            );
            _applicaFiltri();
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Column(
          children: [
            Icon(Icons.add, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'NUOVO VIAGGIO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}