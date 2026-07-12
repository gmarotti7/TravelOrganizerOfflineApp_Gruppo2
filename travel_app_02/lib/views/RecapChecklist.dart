import 'package:flutter/material.dart';
import 'package:travel_app_02/controllers/checklist_controller.dart';
import 'BottomBar.dart';

class RecapChecklist extends StatefulWidget {
  const RecapChecklist({super.key});

  @override
  State<RecapChecklist> createState() => _RecapChecklistState();
}

class _RecapChecklistState extends State<RecapChecklist> {
  final ChecklistController _controller = ChecklistController();
  List<Map<String, dynamic>> _elementi = [];
  bool _caricamento = true;
  late int _idChecklist;
  late String _titolo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_caricamento) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _idChecklist = args['id'] as int;
      _titolo = args['titolo'] as String;
      _caricaElementi();
    }
  }

  Future<void> _caricaElementi() async {
    final elementi = await _controller.caricaElementi(_idChecklist);
    setState(() {
      _elementi = elementi;
      _caricamento = false;
    });
  }

  void _mostraConfermaEliminazione() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE CHECKLIST'),
        content: const Text('Sei sicuro di voler eliminare questa checklist?'),
        actions: [
          TextButton(
            onPressed: () async {
              await _controller.eliminaChecklist(_idChecklist);
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

  @override
  Widget build(BuildContext context) {
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
          'RIEPILOGO CHECKLIST',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onSelected: (valore) {
              if (valore == 'modifica_titolo') _mostraRinominaChecklist();
              if (valore == 'elimina') _mostraConfermaEliminazione();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'modifica_titolo', child: Text('MODIFICA TITOLO')),
              PopupMenuItem(value: 'elimina', child: Text('ELIMINA CHECKLIST')),
            ],
          ),
        ],
      ),
      body: _caricamento
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titolo.toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _elementi.isEmpty
                        ? const Center(child: Text('Nessun elemento in questa checklist'))
                        : ListView.builder(
                            itemCount: _elementi.length,
                            itemBuilder: (context, index) {
                              final item = _elementi[index];
                              final bool completato = (item['isCompletato'] as int) == 1;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    item['nomeItem'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      decoration: completato ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                  ),
                                  secondary: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.black54),
                                    onSelected: (valore) {
                                      if (valore == 'modifica') _mostraModificaElemento(item);
                                      if (valore == 'elimina') _confermaEliminaElemento(item);
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'modifica', child: Text('MODIFICA')),
                                      PopupMenuItem(value: 'elimina', child: Text('ELIMINA')),
                                    ],
                                  ),
                                  value: completato,
                                  activeColor: Colors.black,
                                  checkColor: Colors.amber,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (bool? nuovoValore) async {
                                    await _controller.aggiornaStatoElemento(item['id'] as int, nuovoValore ?? false);
                                    setState(() {
                                      item['isCompletato'] = (nuovoValore ?? false) ? 1 : 0;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}