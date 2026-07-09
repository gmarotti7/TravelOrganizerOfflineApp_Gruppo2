import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app_02/controllers/riepilogo_viaggio_controller.dart';
import 'package:travel_app_02/models/spesa.dart';
import 'package:travel_app_02/models/tappa.dart';

class RiepilogoViaggio extends StatefulWidget {
  final RiepilogoViaggioController controller;

  const RiepilogoViaggio({
    super.key,
    required this.controller,
  });

  @override
  State<RiepilogoViaggio> createState() => _RiepilogoViaggioState();
}

class _RiepilogoViaggioState extends State<RiepilogoViaggio> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateUI);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  String _formatValuta(double importo) {
    return NumberFormat.currency(locale: 'it_IT', symbol: '€').format(importo);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final trip = controller.trip;

    // Colore giallo ocra/arancione di sfondo dell'app
    const Color gialloSfondo = Color(0xFFFFB84D);

    return Scaffold(
      backgroundColor: gialloSfondo, // Tutto lo schermo giallo
      appBar: AppBar(
        backgroundColor: gialloSfondo,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          trip.titolo,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Indicatore dello stato del viaggio
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.statoViaggioColor,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (valore) {
              if (valore == 'modifica') {
                // TODO: Navigator.pushNamed(context, '/modifica-viaggio');
              } else if (valore == 'elimina') {
                // TODO: Mostra dialogo conferma eliminazione
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
            // Descrizione del viaggio centrata
            Text(
              trip.descrizione,
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

                  // Lista delle tappe (cliccabili)
                  if (trip.tappe.isEmpty)
                    const Text("- Nessuna tappa presente", style: TextStyle(fontStyle: FontStyle.italic))
                  else
                    ...trip.tappe.map(
                      (tappa) => InkWell(
                        onTap: () {
                          // Naviga alla schermata riepilogo tappa del collaboratore
                          Navigator.pushNamed(
                            context,
                            '/riepilogo-tappa',
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

                  const SizedBox(height: 16),
                  const Text(
                    "PACKLIST",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Naviga alla pagina riepilogo packlist/checklist
                      Navigator.pushNamed(context, '/riepilogo-packlist');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("- Vedi Packlist", style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "CHECKLIST",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Naviga alla pagina riepilogo checklist
                      Navigator.pushNamed(context, '/riepilogo-checklist');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("- Vedi Checklist", style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 8),

                  // Spese Totale con cambio colore automatico
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SPESE TOT: ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatValuta(controller.speseTotali),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: controller.speseTotaliColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bottone Nero "+ AGGIUNGI SPESA" -> Naviga alla pagina del collaboratore
            ElevatedButton(
              onPressed: () {
                // Porta alla pagina creata dal collaboratore per aggiungere spesa
                Navigator.pushNamed(context, '/nuova-spesa');
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
                  if (trip.spese.isEmpty)
                    const Text("- Nessuna spesa ancora registrata", style: TextStyle(fontStyle: FontStyle.italic))
                  else
                    ...trip.spese.map(
                      (spesa) => InkWell(
                        onTap: () {
                          // Naviga alla pagina riepilogo spesa del collaboratore
                          Navigator.pushNamed(
                            context,
                            '/riepilogo-spesa',
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

            // Budget Previsto in basso
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
}