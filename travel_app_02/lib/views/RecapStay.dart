import 'package:flutter/material.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'EditStayField.dart';
import 'BottomBar.dart';
import 'package:travel_app_02/sessione.dart';

class RecapStay extends StatefulWidget {
  const RecapStay({Key? key}) : super(key: key);

  @override
  State<RecapStay> createState() => _RecapStayState();
}

class _RecapStayState extends State<RecapStay> {
  Stay? _tappa;
  bool _inizializzato = false;
  bool _modificato = false;
  DateTime? _dataInizioViaggio;
  DateTime? _dataFineViaggio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inizializzato) {
      final args = ModalRoute.of(context)!.settings.arguments;
      
      if (args is Map) {
        _tappa = args['tappa'] as Stay;
        _dataInizioViaggio = args['dataInizioViaggio'] as DateTime?;
        _dataFineViaggio = args['dataFineViaggio'] as DateTime?;
      } else if (args is Stay) {
        _tappa = args;
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

  void _mostraConfermaEliminazione(Stay tappaAttuale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE TAPPA'),
        content: Text('Sei sicuro di voler eliminare l\'attività "${tappaAttuale.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () async {
              await StayController().eliminaTappa(tappaAttuale.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                Navigator.pop(context, 'eliminata');
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

  void _mostraMenuModificaTappa(Stay tappaAttuale) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Titolo'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(tappaAttuale, 'titolo', 'Titolo'); }),
            ListTile(title: const Text('Data'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(tappaAttuale, 'data', 'Data'); }),
            ListTile(title: const Text('Ora'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(tappaAttuale, 'ora', 'Ora'); }),
            ListTile(title: const Text('Descrizione'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(tappaAttuale, 'descrizione', 'Descrizione'); }),
            ListTile(title: const Text('Costo Previsto'), onTap: () { Navigator.pop(bottomSheetContext); _apriModificaCampo(tappaAttuale, 'costoPrevisto', 'Costo Previsto'); }),
          ],
        ),
      ),
    );
  }

  Future<void> _apriModificaCampo(Stay tappaAttuale, String campo, String label) async {
    final salvato = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditStayField(),
        settings: RouteSettings(arguments: {'tappa': tappaAttuale, 'campo': campo, 'label': label,'dataInizioViaggio': _dataInizioViaggio, 'dataFineViaggio': _dataFineViaggio,}),
      ),
    );

    if (salvato != null && salvato is Map) {
      setState(() {
        _modificato = true;

        String nTitolo = _tappa!.titolo;
        String nData = _tappa!.data;
        String nOra = _tappa!.ora;
        String? nDescrizione = _tappa!.descrizione;
        double nCosto = _tappa!.costoPrevisto;

        switch (salvato['campo']) {
          case 'titolo': nTitolo = salvato['valore']; break;
          case 'data': nData = salvato['valore']; break;
          case 'ora': nOra = salvato['valore']; break;
          case 'descrizione': nDescrizione = salvato['valore']; break;
          case 'costoPrevisto': nCosto = salvato['valore']; break;
        }


        _tappa = Stay(
          id: _tappa!.id,
          titolo: nTitolo,
          data: nData,
          ora: nOra,
          descrizione: nDescrizione,
          costoPrevisto: nCosto,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappaAttuale = _tappa!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _modificato);
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 193, 7, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 193, 7, 1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () => Navigator.pop(context, _modificato),
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
                  _mostraConfermaEliminazione(tappaAttuale);
                } else if (valore == 'modifica') {
                  _mostraMenuModificaTappa(tappaAttuale);
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
                _buildRecapItem('DATA', tappaAttuale.data.isEmpty ? 'Non specificata' : tappaAttuale.data),
                _buildRecapItem('ORA', tappaAttuale.ora.isEmpty ? 'Non specificata' : tappaAttuale.ora),
                _buildRecapItem('TITOLO', tappaAttuale.titolo),
                _buildRecapItem('COSTO PREVISTO', '${tappaAttuale.costoPrevisto.toStringAsFixed(2)} ${Sessione.valutaAttuale}'),
                const SizedBox(height: 10),
                const Text(
                  'DESCRIZIONE:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  (tappaAttuale.descrizione == null || tappaAttuale.descrizione!.isEmpty)
                      ? 'Nessuna descrizione'
                      : tappaAttuale.descrizione!,
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