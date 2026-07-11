import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:travel_app_02/controllers/riepilogo_viaggio_controller.dart';
import 'package:travel_app_02/models/spesa.dart';
import 'package:travel_app_02/models/tappa.dart';
import 'package:travel_app_02/route.dart';

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
  
  // --- DATI FITTIZI (MOCK) PER IL TEST GRAFICO ---
  final String titoloViaggio = "Vacanza a Roma";
  final String descrizioneViaggio = "Viaggio di relax di 5 giorni nella capitale con visita ai musei e tour gastronomico.";
  final double budgetPrevisto = 800.00;
  final double speseTotali = 135.50;
  final Color coloreStato = Colors.green; // Verde: in corso/tutto ok
  final Color coloreSpeseTotali = Colors.black;
  
  // Liste fittizie per simulare i modelli Tappa e Spesa
  final List<String> tappeFittizie = [
    "Arrivo a Termini e Check-in",
    "Visita al Colosseo",
    "Cena a Trastevere"
  ];
  
  List<Spesa> listaSpese = [
    Spesa(
      id: '1', 
      titolo: "Biglietto Treno", 
      importo: 45.50, 
      stato: 'Pagata', 
      data: '12/08/2026', 
      descrizione: 'Andata e ritorno', 
      metodoPagamento: 'Carta di credito',
      categoria: 'Trasporti',
      viaggioAssociato: 'Vacanza a Roma', 
      attivitaAssociata: 'Spostamento', 
    ),
    Spesa(
      id: '2', 
      titolo: "Cena Carbonara", 
      importo: 35.00, 
      stato: 'Pagata', 
      data: '13/08/2026',
      categoria: 'Cibo e Bevande',
      viaggioAssociato: 'Vacanza a Roma',
      attivitaAssociata: 'Cena in centro',
    ),
  ];


  String _formatValuta(double importo) {
    return NumberFormat.currency(locale: 'it_IT', symbol: '€').format(importo);
  }

  @override
  Widget build(BuildContext context) {
    const Color gialloSfondo = Color(0xFFFFB84D);

    return Scaffold(
      backgroundColor: gialloSfondo,
      appBar: AppBar(
        backgroundColor: gialloSfondo,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          titoloViaggio,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: coloreStato,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (valore) {},
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
              descrizioneViaggio,
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

                  ...tappeFittizie.map(
                    (tappa) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "- $tappa",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
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
                        _formatValuta(speseTotali),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: coloreSpeseTotali,
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
                if (nuovaSpesa != null && nuovaSpesa is Spesa) {
                  setState(() {
                    listaSpese.add(nuovaSpesa);
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
                  ...listaSpese.map(
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
              "BUDGET PREVISTO: ${_formatValuta(budgetPrevisto)}",
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