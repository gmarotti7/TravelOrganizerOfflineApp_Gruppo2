import 'package:flutter/material.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'BottomBar.dart';

class RecapStay extends StatelessWidget {
  const RecapStay({Key? key}) : super(key: key);

  Widget _buildRecapItem(String label, String placeholderValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Expanded(
            child: Text(
              placeholderValue,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _mostraConfermaEliminazione(BuildContext context, Stay tappa) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE TAPPA'),
        content: Text('Sei sicuro di voler eliminare l\'attività "${tappa.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () async {
              await StayController().eliminaTappa(tappa.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // chiude il dialog
              }
              if (context.mounted) {
                Navigator.pop(context, 'eliminata'); // torna al Riepilogo Viaggio
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

  @override
  Widget build(BuildContext context) {
    final tappaPassata = ModalRoute.of(context)!.settings.arguments as Stay;

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'RIEPILOGO TAPPA',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onSelected: (valore) {
              if (valore == 'elimina') {
                _mostraConfermaEliminazione(context, tappaPassata);
              } else if (valore == 'modifica') {
                // TODO: Navigator.pushNamed(context, AppRoutes.newStage, arguments: tappaPassata);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'modifica', child: Text('MODIFICA TAPPA')),
              PopupMenuItem(value: 'elimina', child: Text('ELIMINA TAPPA')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecapItem('DATA', tappaPassata.data.isEmpty ? 'Non specificata' : tappaPassata.data),
              _buildRecapItem('ORA', tappaPassata.ora.isEmpty ? 'Non specificata' : tappaPassata.ora),
              _buildRecapItem('TITOLO', tappaPassata.titolo),
              _buildRecapItem('COSTO PREVISTO', '${tappaPassata.costoPrevisto.toStringAsFixed(2)} EUR'),
              const SizedBox(height: 10),
              const Text(
                'DESCRIZIONE:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 5),
              Text(
                (tappaPassata.descrizione == null || tappaPassata.descrizione!.isEmpty)
                    ? 'Nessuna descrizione'
                    : tappaPassata.descrizione!,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}