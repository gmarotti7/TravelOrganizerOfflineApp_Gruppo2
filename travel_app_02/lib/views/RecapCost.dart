import 'package:flutter/material.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/controllers/cost_controller.dart';
import 'EditCostField.dart';
import 'BottomBar.dart';
import 'package:travel_app_02/sessione.dart';

class RecapCost extends StatefulWidget {
  const RecapCost({Key? key}) : super(key: key);

  @override
  State<RecapCost> createState() => _RecapCostState();
}

class _RecapCostState extends State<RecapCost> {
  final CostController _costController = CostController();
  Expense? _spesa;
  String? _nomeViaggio;
  bool _inizializzato = false;
  bool _modificato = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inizializzato) {
      final args = ModalRoute.of(context)!.settings.arguments;
      
      // Controlliamo se stiamo ricevendo la Mappa (nuovo metodo) o solo la Spesa
      if (args is Map<String, dynamic>) {
        _spesa = args['spesa'] as Expense;
        _nomeViaggio = args['nomeViaggio'] as String;
      } else if (args is Expense) {
        _spesa = args;
      }
      
      _inizializzato = true;
    }
  }

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

  void _mostraConfermaEliminazione(Expense spesa) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE SPESA'),
        content: Text('Sei sicuro di voler eliminare la spesa "${spesa.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () async {
              await CostController().eliminaSpesa(spesa.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) Navigator.pop(context, true);
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

  void _mostraMenuModifica(Expense spesa) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('Titolo'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'titolo', 'Titolo'); }),
              ListTile(title: const Text('Importo'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'importo', 'Importo'); }),
              ListTile(title: const Text('Stato'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'stato', 'Stato'); }),
              ListTile(title: const Text('Data'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'data', 'Data'); }),
              ListTile(title: const Text('Metodo Pagamento'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'metodoPagamento', 'Metodo Pagamento'); }),
              ListTile(title: const Text('Categoria'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'categoria', 'Categoria'); }),
              ListTile(title: const Text('Attività Associata'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'attivitaAssociata', 'Attività Associata'); }),
              ListTile(title: const Text('Nota'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'descrizione', 'Nota'); }),
              ListTile(title: const Text('Valuta'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(spesa, 'valuta', 'Valuta'); }),
            ],
          ),
        ),
      ),
    );
  }

  // NOTA: usiamo sempre il context della pagina RecapCost (State.context), che resta valido
  // per tutta la durata dell'operazione, invece del context (transitorio) del bottom sheet
  // che veniva chiuso poco prima: quello risultava già "smontato" al termine del salvataggio
  // e impediva l'aggiornamento della pagina.
  Future<void> _apriModificaCampo(Expense spesa, String campo, String label) async {
    final salvato = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditCostField(),
        settings: RouteSettings(arguments: {'spesa': spesa, 'campo': campo, 'label': label}),
      ),
    );

    if (salvato == true) {
      // Ricarichiamo la spesa aggiornata dal database e la mostriamo subito,
      // senza dover uscire e rientrare nella pagina di riepilogo.
      final spesaAggiornata = await _costController.caricaSpesa(spesa.id);
      if (mounted && spesaAggiornata != null) {
        setState(() {
          _spesa = spesaAggiornata;
          _modificato = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spesaPassata = _spesa!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _modificato);
        }
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 193, 7, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 193, 7, 1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () => Navigator.pop(context, _modificato),
          ),
          centerTitle: true,
          title: const Text(
            'RIEPILOGO',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onSelected: (valore) {
                if (valore == 'elimina') {
                  _mostraConfermaEliminazione(spesaPassata);
                } else if (valore == 'modifica') {
                  _mostraMenuModifica(spesaPassata);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'modifica', child: Text('MODIFICA SPESA')),
                PopupMenuItem(value: 'elimina', child: Text('ELIMINA SPESA')),
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
                _buildRecapItem('TITOLO', spesaPassata.titolo),
                _buildRecapItem('IMPORTO', '${spesaPassata.importo.toStringAsFixed(2)} ${spesaPassata.valuta ?? Sessione.valutaAttuale}'),
                _buildRecapItem('STATO', spesaPassata.stato ?? 'Non specificato'),
                _buildRecapItem('DATA', spesaPassata.data ?? 'Non specificata'),
                _buildRecapItem('METODO DI PAGAMENTO', spesaPassata.metodoPagamento ?? 'Non specificato'),
                _buildRecapItem('CATEGORIA', spesaPassata.categoria ?? 'Non Specificato'),
                _buildRecapItem('VIAGGIO ASSOCIATO', _nomeViaggio ?? spesaPassata.viaggioAssociato ?? 'Non specificato'),
                _buildRecapItem('ATTIVITÀ ASSOCIATA', spesaPassata.attivitaAssociata ?? 'Non specificata'),
                const SizedBox(height: 10),
                const Text(
                  'NOTE:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  spesaPassata.descrizione?.isNotEmpty == true ? spesaPassata.descrizione! : 'Nessuna nota',
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}