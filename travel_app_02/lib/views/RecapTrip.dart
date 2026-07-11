import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app_02/controllers/rec_trip_controller.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/models/trip.dart';


import 'package:travel_app_02/route.dart';

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
  List<Stay> _tappe = [];
  bool _caricamentoTappe = true;

  @override
  void initState() {
    super.initState();
    _caricaTappe();
  }

  Future<void> _caricaTappe() async {
    final idViaggio = int.tryParse(widget.controller.trip.id);
    if (idViaggio == null) {
      setState(() => _caricamentoTappe = false);
      return;
    }
    final tappeDb = await _tappaController.caricaTappeViaggio(idViaggio);
    setState(() {
      _tappe = tappeDb;
      _caricamentoTappe = false;
    });
  }

  String _formatValuta(double importo) {
    return NumberFormat.currency(locale: 'it_IT', symbol: '€').format(importo);
  }

  @override
  Widget build(BuildContext context) {
    const Color gialloSfondo = Color(0xFFFFB84D);
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
                // TODO: Navigator.pushNamed(context, AppRoutes.addTrip, arguments: trip);
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
            // La descrizione non è ancora un campo di Viaggio: se/quando verrà aggiunta
            // dal tuo compagno nella creazione viaggio, va sostituita qui sotto.
            Text(
              trip.luogo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recapStay,
                            arguments: tappa,
                          );
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
                  OutlinedButton(
                    onPressed: () async {
                      final idViaggio = int.tryParse(trip.id);
                      if (idViaggio == null) return;
                      final risultato = await Navigator.pushNamed(context, AppRoutes.newStay);
                      if (risultato != null && risultato is Stay) {
                        final tappaSalvata = await _tappaController.salvaNuovaTappa(risultato, idViaggio);
                        setState(() => _tappe.add(tappaSalvata));
                      }
                    },
                    child: const Text("+ Aggiungi Tappa"),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "PACKLIST",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("- Vedi Packlist", style: TextStyle(fontWeight: FontWeight.w500)),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "CHECKLIST",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("- Vedi Checklist", style: TextStyle(fontWeight: FontWeight.w500)),
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
                        _formatValuta(widget.controller.speseTotali),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.controller.speseTotaliColor,
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
                final nuovaSpesa = await Navigator.pushNamed(context, AppRoutes.newCost);
                if (nuovaSpesa != null && nuovaSpesa is Expense) {
                  setState(() {
                    widget.controller.aggiungiSpesa(nuovaSpesa);
                  });
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

            // Contenitore Bianco per la LISTA SPESE
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
                  const Text(
                    "LISTA SPESE:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...trip.spese.map(
                    (spesa) => InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recapCost,
                          arguments: spesa,
                        );
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
                            Text(
                              "- ${spesa.titolo}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _formatValuta(spesa.importo),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
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

  void _mostraConfermaEliminazioneViaggio(BuildContext context) {
    final trip = widget.controller.trip;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE VIAGGIO'),
        content: Text('Sei sicuro di voler eliminare il viaggio "${trip.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: chiamare un metodo tipo ViaggioController.eliminaViaggio(trip.id)
              // e poi tornare alla Home rimuovendo questa schermata dallo stack.
              Navigator.pop(context);
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
}