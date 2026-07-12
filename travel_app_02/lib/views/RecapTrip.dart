import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:travel_app_02/controllers/rec_trip_controller.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'package:travel_app_02/controllers/trip_controller.dart';
import 'package:travel_app_02/controllers/checklist_controller.dart';
import 'package:travel_app_02/controllers/pack_controller.dart';
import 'package:travel_app_02/controllers/cost_controller.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/route.dart';
import 'package:travel_app_02/sessione.dart';

class RecapTrip extends StatefulWidget {
  final RecTripController controller;

  const RecapTrip({
    super.key,
    required this.controller,
  });

  @override
  State<RecapTrip> createState() => _RecapTripState();
}

class _RecapTripState extends State<RecapTrip> {
  final StayController _tappaController = StayController();
  final ChecklistController _checklistController = ChecklistController();
  final PackController _packController = PackController();
  final CostController _costController = CostController();
  String? _valutaTotaleSelezionata;

  List<Stay> _tappe = [];
  bool _caricamentoTappe = true;
  bool _caricamentoSpese = true;

  Map<String, dynamic>? _checklist; // {id, titolo} oppure null se non esiste ancora
  Map<String, dynamic>? _packlist;

  final Map<String, double> _tassiDiCambio = {
    'EUR': 1.0,
    'USD': 1.10,
    'GBP': 0.85,
    'JPY': 160.0,
    'CHF': 0.95,
  };

  @override
  void initState() {
    super.initState();
    _caricaTutto();
  }

  Future<void> _caricaTutto() async {
    await Future.wait([
      _caricaTappe(),
      _caricaChecklist(),
      _caricaPacklist(),
      _caricaSpese(),
    ]);
  }

  Future<void> _caricaSpese() async {
    final idViaggio = int.tryParse(widget.controller.trip.id);
    if (idViaggio == null) {
      setState(() => _caricamentoSpese = false);
      return;
    }
    try {
      final speseDb = await _costController.caricaSpeseViaggio(idViaggio);
      setState(() {
        widget.controller.trip.spese = speseDb;
        _caricamentoSpese = false;
      });
    } catch (e) {
      setState(() => _caricamentoSpese = false);
      _mostraErrore('Errore caricando le spese: $e');
    }
  }

  double _calcolaSpeseTotaliConvertite(String valutaTarget) {
    double totale = 0.0;
    for (var spesa in widget.controller.trip.spese) {
      String valutaSpesa = spesa.valuta ?? Sessione.valutaAttuale;
      
      if (valutaSpesa == valutaTarget) {
        totale += spesa.importo;
      } else {
        // Converte in Euro e poi nella valuta Target
        double inEuro = spesa.importo / (_tassiDiCambio[valutaSpesa] ?? 1.0);
        totale += inEuro * (_tassiDiCambio[valutaTarget] ?? 1.0);
      }
    }
    return totale;
  }

  Color _getSpeseTotaliColor() {
    double totaleInValutaUtente = _calcolaSpeseTotaliConvertite(Sessione.valutaAttuale);
    return totaleInValutaUtente > widget.controller.trip.budgetPrevisto ? Colors.red : Colors.green;
  }

  Future<void> _caricaTappe() async {
    final idViaggio = int.tryParse(widget.controller.trip.id);
    if (idViaggio == null) {
      setState(() => _caricamentoTappe = false);
      return;
    }
    try {
      final tappeDb = await _tappaController.caricaTappeViaggio(idViaggio);
      setState(() {
        _tappe = tappeDb;
        _caricamentoTappe = false;
      });
    } catch (e) {
      setState(() => _caricamentoTappe = false);
      _mostraErrore('Errore caricando le tappe: $e');
    }
  }

  Future<void> _caricaChecklist() async {
    final idViaggio = int.tryParse(widget.controller.trip.id);
    if (idViaggio == null) return;
    final risultato = await _checklistController.caricaChecklistViaggio(idViaggio);
    if (mounted) setState(() => _checklist = risultato);
  }

  Future<void> _caricaPacklist() async {
    final idViaggio = int.tryParse(widget.controller.trip.id);
    if (idViaggio == null) return;
    final risultato = await _packController.caricaPacklistViaggio(idViaggio);
    if (mounted) setState(() => _packlist = risultato);
  }

  void _mostraErrore(String messaggio) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messaggio), backgroundColor: Colors.red),
    );
  }

  String _formatValuta(double importo, {String? valutaSpecifica}) {
    return NumberFormat.currency(locale: 'it_IT', symbol: valutaSpecifica ?? Sessione.valutaAttuale).format(importo);
  }

  // --- NUOVA FUNZIONE PER GESTIRE IL FORMATO DATE ---
  String _formattaDataSafely(dynamic data) {
    if (data == null || data.toString().isEmpty) return 'N/D';
    if (data is DateTime) {
      return DateFormat('dd/MM/yyyy').format(data);
    }
    if (data is String) {
      try {
        final parsed = DateTime.parse(data);
        return DateFormat('dd/MM/yyyy').format(parsed);
      } catch (e) {
        return data; // Ritorna la stringa così come l'hai salvata
      }
    }
    return data.toString();
  }

  @override
  Widget build(BuildContext context) {
    const Color gialloSfondo = Colors.amber;
    final trip = widget.controller.trip;

    return Scaffold(
      backgroundColor: gialloSfondo,
      appBar: AppBar(
        backgroundColor: gialloSfondo,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          trip.titolo,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.controller.statoViaggioColor,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (valore) {
              if (valore == 'elimina') {
                _mostraConfermaEliminazioneViaggio(context);
              } else if (valore == 'modifica') {
                _mostraMenuModificaViaggio(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'modifica', child: Text('MODIFICA VIAGGIO')),
              PopupMenuItem(value: 'elimina', child: Text('ELIMINA VIAGGIO')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              trip.luogo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // --- NUOVO BLOCCO DATE VISIVE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.black87),
                const SizedBox(width: 5),
                Text(
                  _formattaDataSafely(trip.dataInizio),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("➔", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const Icon(Icons.calendar_month, size: 18, color: Colors.black87),
                const SizedBox(width: 5),
                Text(
                  _formattaDataSafely(trip.dataFine),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            // ---------------------------------

            const SizedBox(height: 20),

            // Contenitore Bianco per TAPPE, PACKLIST e CHECKLIST
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    "TAPPE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  if (_caricamentoTappe)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    )
                  else if (_tappe.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Nessuna tappa ancora aggiunta"),
                    )
                  else
                    ..._tappe.map(
                      (tappa) => InkWell(
                        onTap: () async {
                          final aggiorna = await Navigator.pushNamed(
                            context,
                            AppRoutes.recapStay,
                            arguments: tappa,
                          );
                          if (aggiorna == true) {
                            _caricaTappe();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "- ${tappa.titolo}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // PULSANTE AGGIUNGI TAPPA
                  OutlinedButton(
                    onPressed: () async {
                      final risultato = await Navigator.pushNamed(
                        context,
                        AppRoutes.newStay,
                        arguments: trip, // Serve a NewStay per limitare la data tra inizio e fine viaggio
                      );
                      if (risultato != null && risultato is Stay) {
                        final idViaggio = int.tryParse(trip.id);
                        if (idViaggio == null) {
                          _mostraErrore('ID viaggio non valido, impossibile salvare la tappa.');
                          return;
                        }
                        try {
                          final tappaSalvata = await _tappaController.salvaNuovaTappa(risultato, idViaggio);
                          setState(() => _tappe.add(tappaSalvata));
                        } catch (e) {
                          // Se vedi qui un errore "no such column" o "no such table",
                          // devi disinstallare l'app dall'emulatore (il database salvato
                          // è vecchio e non ha ancora lo schema aggiornato).
                          _mostraErrore('Errore salvando la tappa: $e');
                        }
                      }
                    },
                    child: const Text("+ Aggiungi Tappa"),
                  ),

                  const SizedBox(height: 16),
                  const Text("PACKLIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  InkWell(
                    // La packlist si sceglie solo in fase di creazione del viaggio:
                    // qui è consultabile solo se ne è stata scelta una allora.
                    onTap: _packlist == null ? null : () => _apriPacklist(context, trip),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _packlist == null ? "Nessuna packlist selezionata" : "- ${_packlist!['titolo']}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _packlist == null ? Colors.black45 : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text("CHECKLIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () => _apriChecklist(context, trip),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _checklist == null ? "+ Crea Checklist" : "- ${_checklist!['titolo']}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SPESE TOT: ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatValuta(
                          _calcolaSpeseTotaliConvertite(_valutaTotaleSelezionata ?? Sessione.valutaAttuale),
                          valutaSpecifica: _valutaTotaleSelezionata ?? Sessione.valutaAttuale,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _getSpeseTotaliColor(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade300,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: DropdownButton<String>(
                          value: _valutaTotaleSelezionata ?? Sessione.valutaAttuale,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                          isDense: true,
                          items: ['EUR', 'USD', 'GBP', 'JPY', 'CHF'].map((String valuta) {
                            return DropdownMenuItem<String>(
                              value: valuta,
                              child: Text(valuta),
                            );
                          }).toList(),
                          onChanged: (nuovaValuta) {
                            if (nuovaValuta != null) {
                              setState(() {
                                _valutaTotaleSelezionata = nuovaValuta;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final nuovaSpesa = await Navigator.pushNamed(context, AppRoutes.newCost, arguments: widget.controller.trip);
                if (nuovaSpesa != null && nuovaSpesa is Expense) {
                  final idViaggio = int.tryParse(trip.id);
                  if (idViaggio == null) {
                    _mostraErrore('ID viaggio non valido, impossibile salvare la spesa.');
                    return;
                  }
                  try {
                    await _costController.salvaSpesa(nuovaSpesa, idViaggio);
                    await _caricaSpese();
                  } catch (e) {
                    // Se vedi qui un errore "no such column", devi disinstallare l'app
                    // dall'emulatore (il database salvato è vecchio e non ha ancora
                    // le nuove colonne di 'spese': stato, descrizione, metodoPagamento, ecc.)
                    _mostraErrore('Errore salvando la spesa: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "+ AGGIUNGI SPESA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // LISTA SPESE
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LISTA SPESE:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_caricamentoSpese)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    )
                  else if (trip.spese.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Nessuna spesa ancora aggiunta"),
                    )
                  else
                    ...trip.spese.map(
                      (spesa) => InkWell(
                        onTap: () async {
                          final aggiorna = await Navigator.pushNamed(
                            context,
                            AppRoutes.recapCost,
                            arguments: spesa,
                          );
                          if (aggiorna == true) {
                            _caricaSpese();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("- ${spesa.titolo}", style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(_formatValuta(spesa.importo, valutaSpecifica: spesa.valuta), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "BUDGET PREVISTO: ${_formatValuta(trip.budgetPrevisto)}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------- PACKLIST / CHECKLIST ----------

  Future<void> _apriPacklist(BuildContext context, Trip trip) async {
    final idViaggio = int.tryParse(trip.id);
    final packlist = _packlist;
    if (idViaggio == null || packlist == null) return;

    final risultato = await Navigator.pushNamed(
      context,
      AppRoutes.recapPacklist,
      arguments: {'id': packlist['id'], 'titolo': packlist['titolo']},
    );
    if (risultato == true) {
      _caricaPacklist(); // è stata eliminata, ricarichiamo (tornerà a "Nessuna packlist selezionata")
    }
  }

  Future<void> _apriChecklist(BuildContext context, Trip trip) async {
    final idViaggio = int.tryParse(trip.id);
    if (idViaggio == null) return;

    if (_checklist == null) {
      final risultato = await Navigator.pushNamed(context, AppRoutes.addCheck);
      if (risultato != null && risultato is Map) {
        try {
          await _checklistController.salvaChecklist(
            risultato['titolo'] as String,
            List<Map<String, dynamic>>.from(risultato['elementi'] as List),
            idViaggio,
          );
          await _caricaChecklist();
        } catch (e) {
          _mostraErrore('Errore salvando la checklist: $e');
        }
      }
    } else {
      final risultato = await Navigator.pushNamed(
        context,
        AppRoutes.recapChecklist,
        arguments: {'id': _checklist!['id'], 'titolo': _checklist!['titolo']},
      );
      if (risultato == true) {
        _caricaChecklist();
      }
    }
  }

  // ---------- ELIMINA / MODIFICA VIAGGIO ----------

  void _mostraConfermaEliminazioneViaggio(BuildContext context) {
    final trip = widget.controller.trip;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE VIAGGIO'),
        content: Text('Sei sicuro di voler eliminare il viaggio "${trip.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await TripController().eliminaViaggio(trip.id);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
              }
            },
            child: const Text('SÌ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  // Menu a tendina: quale campo del viaggio vuoi modificare
  void _mostraMenuModificaViaggio(BuildContext context) {
    final trip = widget.controller.trip;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Titolo'),
              onTap: () => _apriModificaCampo(context, trip, 'titolo', 'Titolo'),
            ),
            ListTile(
              title: const Text('Luogo'),
              onTap: () => _apriModificaCampo(context, trip, 'luogo', 'Luogo'),
            ),
            ListTile(
              title: const Text('Data Inizio'),
              onTap: () => _apriModificaCampo(context, trip, 'dataInizio', 'Data Inizio'),
            ),
            ListTile(
              title: const Text('Data Fine'),
              onTap: () => _apriModificaCampo(context, trip, 'dataFine', 'Data Fine'),
            ),
            ListTile(
              title: const Text('Budget Previsto'),
              onTap: () => _apriModificaCampo(context, trip, 'budgetPrevisto', 'Budget Previsto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apriModificaCampo(BuildContext context, Trip trip, String campo, String label) async {
    Navigator.pop(context); // chiude il menu a tendina

    final risultato = await Navigator.pushNamed(
      context,
      AppRoutes.editTripField,
      arguments: {'trip': trip, 'campo': campo, 'label': label},
    );

    if (risultato != null && risultato is Map) {
      setState(() {
        switch (risultato['campo']) {
          case 'titolo':
            trip.titolo = risultato['valore'];
            break;
          case 'luogo':
            trip.luogo = risultato['valore'];
            break;
          case 'dataInizio':
            trip.dataInizio = risultato['valore'];
            break;
          case 'dataFine':
            trip.dataFine = risultato['valore'];
            break;
          case 'budgetPrevisto':
            trip.budgetPrevisto = risultato['valore'];
            break;
        }
      });
    }
  }
}