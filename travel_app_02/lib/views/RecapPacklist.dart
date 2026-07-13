import 'package:flutter/material.dart';
import 'package:travel_app_02/controllers/pack_controller.dart';
import 'BottomBar.dart';

class RecapPacklist extends StatefulWidget {
  const RecapPacklist({super.key});

  @override
  State<RecapPacklist> createState() => _RecapPacklistState();
}

class _RecapPacklistState extends State<RecapPacklist> {
  final PackController _controller = PackController();
  List<Map<String, dynamic>> _elementi = [];
  bool _caricamento = true;
  late int _idPacklist;
  late String _titolo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_caricamento) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _idPacklist = args['id'] as int;
      _titolo = args['titolo'] as String;
      _caricaElementi();
    }
  }

  Future<void> _caricaElementi() async {
    final elementi = await _controller.caricaElementi(_idPacklist);
    setState(() {
      _elementi = elementi.map((e) => Map<String, dynamic>.from(e)).toList();
      _caricamento = false;
    });
  }

  void _mostraConfermaEliminazione() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFERMA ELIMINAZIONE PACKLIST'),
        content: const Text('Sei sicuro di voler eliminare questa packlist?'),
        actions: [
          TextButton(
            onPressed: () async {
              await _controller.eliminaPacklist(_idPacklist);
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
      backgroundColor: Color.fromRGBO(255, 193, 7, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 193, 7, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'RIEPILOGO PACKLIST',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onSelected: (valore) {
              if (valore == 'elimina') _mostraConfermaEliminazione();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'elimina', child: Text('ELIMINA PACKLIST')),
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
                        ? const Center(child: Text('Nessun elemento in questa packlist'))
                        : ListView.builder(
                            itemCount: _elementi.length,
                            itemBuilder: (context, index) {
                              final item = _elementi[index];
                              final bool imballato = (item['isImballato'] as int) == 1;
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
                                      decoration: imballato ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                  ),
                                  value: imballato,
                                  activeColor: Colors.black,
                                  checkColor: Color.fromRGBO(255, 193, 7, 1),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (bool? nuovoValore) async {
                                    try {
                                      await _controller.aggiornaStatoElemento(item['id'] as int, nuovoValore ?? false);
                                      setState(() {
                                        _elementi[index] = {
                                          ...item,
                                          'isImballato': (nuovoValore ?? false) ? 1 : 0,
                                        };
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