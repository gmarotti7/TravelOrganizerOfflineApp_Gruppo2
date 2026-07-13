// lib/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/controllers/checklist_controller.dart';
import 'package:travel_app_02/route.dart';
import 'BottomBar.dart';
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/sessione.dart';
import 'package:travel_app_02/controllers/trip_controller.dart';
import 'package:travel_app_02/controllers/pack_controller.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'package:travel_app_02/models/stay.dart';

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

  // Lista simulata di viaggi (Database temporaneo per presentazione)
  final List<Trip> _tuttiIViaggi = [
    Trip(titolo: 'Vacanze Romane', luogo: 'Roma', dataInizio: DateTime(2026, 07, 01), id: '0001', dataFine: DateTime(2026, 07, 09), budgetPrevisto: 500), 
    Trip(titolo: 'Vacanze Estive', luogo: 'Barcellona', dataInizio: DateTime(2026, 07, 10), id: '0002', dataFine: DateTime(2026, 07, 20), budgetPrevisto: 800), 
    Trip(titolo: 'Weekend in Montagna', luogo: 'Trento', dataInizio: DateTime(2026, 07, 22), id: '0003', dataFine: DateTime(2026, 07, 31), budgetPrevisto: 400), 
  ];

  // Lista che contiene i viaggi filtrati da mostrare sulla UI
  List<Trip> _viaggiFiltrati = [];

  final TripController _controller = TripController();
  
  @override
  void initState() {
    super.initState();
    // Inizializza subito la lista filtrata con i dati mock di default
    _viaggiFiltrati = List.from(_tuttiIViaggi);

    // Aspetta che l'interfaccia sia pronta prima di caricare dal Database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDatiDalDatabase();
    });
  }

  Future<void> _caricaDatiDalDatabase() async {
    if (Sessione.idUtenteAttuale != null) {
      try {
        List<Trip> viaggiDb = await _controller.caricaViaggiUtente(Sessione.idUtenteAttuale!);
      
        bool haViaggiDiProva = viaggiDb.any((v) => v.titolo == 'Vacanze Romane');

        if (!haViaggiDiProva) {
          await _controller.salvaNuovoViaggio(
            Trip(id: '', titolo: 'Vacanze Romane', luogo: 'Roma', dataInizio: DateTime(2026, 07, 01), dataFine: DateTime(2026, 07, 09), budgetPrevisto: 500),
            Sessione.idUtenteAttuale!
          );
          await _controller.salvaNuovoViaggio(
            Trip(id: '', titolo: 'Vacanze Estive', luogo: 'Barcellona', dataInizio: DateTime(2026, 07, 10), dataFine: DateTime(2026, 07, 20), budgetPrevisto: 800),
            Sessione.idUtenteAttuale!
          );
          await _controller.salvaNuovoViaggio(
            Trip(id: '', titolo: 'Weekend in Montagna', luogo: 'Trento', dataInizio: DateTime(2026, 07, 22), dataFine: DateTime(2026, 07, 31), budgetPrevisto: 400),
            Sessione.idUtenteAttuale!
          );
          viaggiDb = await _controller.caricaViaggiUtente(Sessione.idUtenteAttuale!);
        }

        if (!mounted) return;

        setState(() {
          _tuttiIViaggi.clear();
          _tuttiIViaggi.addAll(viaggiDb); 

          _viaggiFiltrati = List.from(_tuttiIViaggi);
          _applicaFiltri(); 
        });
      } catch (e) {
        debugPrint("Errore caricamento DB: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore caricamento dati: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applicaFiltri() {
    String query = _searchController.text.toLowerCase().trim();
    DateTime oggi = DateTime.now();

    setState(() {
      _viaggiFiltrati = _tuttiIViaggi.where((viaggio) {
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
      backgroundColor: Color.fromRGBO(255, 193, 7, 1), // Giallo ocra
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
                  // MODIFICATO: Testo del placeholder aggiornato qui sotto
                  hintText: 'TITOLO, DESTINAZIONE, DATA',
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
                          DateTime soloDataOggi = DateTime(oggi.year, oggi.month, oggi.day);
                          DateTime inizio = DateTime(viaggio.dataInizio.year, viaggio.dataInizio.month, viaggio.dataInizio.day);
                          DateTime fine = DateTime(viaggio.dataFine.year, viaggio.dataFine.month, viaggio.dataFine.day);

                          Color coloreStato;
                          if (soloDataOggi.isBefore(inizio)) {
                            coloreStato = Colors.green;
                          } else if (soloDataOggi.isAfter(fine)) {
                            coloreStato = Colors.red;
                          } else {
                            coloreStato = Colors.yellowAccent;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: InkWell(
                              onTap: () {
                                debugPrint("Cliccato sul viaggio: ${viaggio.titolo}");
                                Navigator.pushNamed(context, AppRoutes.riepilogoViaggio, arguments: viaggio);
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
                                        color: coloreStato,
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
          final nuovoViaggio = risultato['viaggio'] as Trip;
          final int idUtente = Sessione.idUtenteAttuale ?? 1;

          try {
            final salvato = await TripController().salvaNuovoViaggio(nuovoViaggio, idUtente);

            if (risultato.containsKey('tappe')) {
              final tappeScelte = risultato['tappe'] as List;
              for (final tappa in tappeScelte) {
                if (tappa is Stay) {
                  await StayController().salvaNuovaTappa(tappa, int.parse(salvato.id));
                }
              }
            }

            if (risultato['packlist'] != null && risultato['packlistItems'] != null) {
              await PackController().salvaPacklist(
                risultato['packlist'],
                risultato['packlistItems'],
                int.parse(salvato.id),
              );
            }

            if (risultato['checklist'] != null && risultato['checklistItems'] != null) {
              await ChecklistController().salvaChecklist(
                risultato['checklist'],
                risultato['checklistItems'],
                int.parse(salvato.id),
              );
            }

            setState(() {
              _tuttiIViaggi.add(salvato);
              _applicaFiltri();
            });
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Errore di salvataggio: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
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