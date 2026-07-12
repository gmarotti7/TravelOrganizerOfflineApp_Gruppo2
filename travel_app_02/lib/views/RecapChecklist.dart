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
      // Creiamo una copia modificabile di ogni singola mappa restituita dal database
      _elementi = elementi.map((e) => Map<String, dynamic>.from(e)).toList();
      _caricamento = false;
    });
  }

  void _mostraRinominaChecklist() {
    final controller = TextEditingController(text: _titolo);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('MODIFICA TITOLO CHECKLIST'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final nuovoTitolo = controller.text.trim();
              if (nuovoTitolo.isEmpty) return;
              await _controller.aggiornaTitolo(_idChecklist, nuovoTitolo);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              setState(() => _titolo = nuovoTitolo);
            },
            child: const Text('SALVA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
        ],
      ),
    );
  }

  void _mostraModificaElemento(Map<String, dynamic> item) {
    final controller = TextEditingController(text: item['nomeItem'] as String);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('MODIFICA ELEMENTO'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final nuovoNome = controller.text.trim();
              if (nuovoNome.isEmpty) return;
              try {
                await _controller.aggiornaNomeElemento(item['id'] as int, nuovoNome);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) setState(() => item['nomeItem'] = nuovoNome);
              } catch (e) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore modificando l\'elemento: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('SALVA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
        ],
      ),
    );
  }

  void _confermaEliminaElemento(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ELIMINA ELEMENTO'),
        content: Text('Eliminare "${item['nomeItem']}" dalla checklist?'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _controller.eliminaElemento(item['id'] as int);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  setState(() => _elementi.removeWhere((e) => e['id'] == item['id']));
                }
              } catch (e) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore eliminando l\'elemento: $e'), backgroundColor: Colors.red),
                  );
                }
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
                                key: ValueKey(item['id']),
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
                                    try {
                                      await _controller.aggiornaStatoElemento(item['id'] as int, nuovoValore ?? false);
                                      setState(() {
                                        item['isCompletato'] = (nuovoValore ?? false) ? 1 : 0;
                                      });
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Errore aggiornando l\'elemento: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
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