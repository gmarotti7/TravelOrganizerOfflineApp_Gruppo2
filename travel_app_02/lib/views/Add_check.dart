// lib/views/add_check.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/services/database_helper.dart';

class AddCheck extends StatefulWidget {
  final Map<String, dynamic>? checklistIniziale;
  final List<Map<String, dynamic>>? checklistSalvate;

  const AddCheck({super.key, this.checklistIniziale, this.checklistSalvate});

  @override
  State<AddCheck> createState() => _AddCheckState();
}

class _AddCheckState extends State<AddCheck> {
  final _titleController = TextEditingController();
  final _itemController = TextEditingController();

  // Lista dinamica che conterrà gli elementi della checklist corrente
  final List<Map<String, dynamic>> _elementiChecklist = [];

  // Lista centralizzata che conterrà le checklist recuperate dal DB
  List<Map<String, dynamic>> _checklistsDisponibili = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Avvia il caricamento automatico dal database appena si apre la pagina
    _caricaChecklistDalDatabase();

    // Se riceviamo dati in ingresso per la modifica, li carichiamo nei campi
    if (widget.checklistIniziale != null) {
      _titleController.text = widget.checklistIniziale!['titolo'] ?? '';
      
      if (widget.checklistIniziale!.containsKey('elementi')) {
        setState(() {
          _elementiChecklist.addAll(
              List<Map<String, dynamic>>.from(widget.checklistIniziale!['elementi'])
          );
        });
      }
    }
  }

  // MODIFICA: Configurato l'accesso reale alle tabelle del tuo DatabaseHelper
  Future<void> _caricaChecklistDalDatabase() async {
    if (widget.checklistSalvate != null && widget.checklistSalvate!.isNotEmpty) {
      setState(() {
        _checklistsDisponibili = widget.checklistSalvate!;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Prendo tutti i record dalla tabella 'checklist'
      final recordChecklist = await DatabaseHelper.instance.queryAllRows('checklist');
      List<Map<String, dynamic>> listaCompleta = [];

      // 2. Per ciascuna checklist, recupero i relativi sotto-elementi
      for (var chk in recordChecklist) {
        final idChecklist = chk['id'];
        final titoloChecklist = chk['titolo'];

        // Eseguo la query filtrando per l'ID della checklist corrente
        final recordItems = await DatabaseHelper.instance.queryAllRows(
          'checklist_items',
          where: 'idChecklist = ?',
          whereArgs: [idChecklist],
        );

        // Mappo i dati del DB nel formato corretto per l'interfaccia grafica
        List<Map<String, dynamic>> elementiMappati = recordItems.map((item) {
          return {
            'nome': item['nomeItem'], // Usiamo il nome esatto della colonna del tuo DB
            'isChecked': false,       // Forziamo a false per importarla pulita nel nuovo viaggio
          };
        }).toList();

        listaCompleta.add({
          'titolo': titoloChecklist,
          'elementi': elementiMappati,
        });
      }

      setState(() {
        _checklistsDisponibili = listaCompleta;
      });
    } catch (errore) {
      print("Errore durante il recupero delle checklist: $errore");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _aggiungiElemento(String testo) {
    String pulito = testo.trim();
    if (pulito.isEmpty) return;

    setState(() {
      _elementiChecklist.add({
        'nome': pulito,
        'isChecked': false, 
      });
    });

    _itemController.clear();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 193, 7, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pop(context); 
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              // MODIFICA: Inserito SingleChildScrollView per gestire l'apertura della tastiera
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    const Text(
                      'LA TUA CHECKLIST:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    else if (_checklistsDisponibili.isNotEmpty) ...[
                      DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.grey[900],
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        hint: const Text(
                          'IMPORTA DA SALVATE',
                          style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                        ),
                        items: _checklistsDisponibili.map((chk) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: chk,
                            child: Text(
                              chk['titolo']?.toString().toUpperCase() ?? 'SENZA NOME',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (valore) {
                          if (valore != null) {
                            setState(() {
                              _titleController.text = valore['titolo'] ?? '';
                              _elementiChecklist.clear();
                              if (valore.containsKey('elementi')) {
                                for (var elemento in valore['elementi']) {
                                  _elementiChecklist.add({
                                    'nome': elemento['nome'],
                                    'isChecked': false, 
                                  });
                                }
                              }
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checklist importata con successo!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                    ],

                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      cursorColor: Colors.white,
                      decoration: _buildInputDecoration('TITOLO'),
                    ),

                    const SizedBox(height: 35),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'COSA VUOI AGGIUNGERE?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            cursorColor: Colors.white,
                            decoration: _buildInputDecoration('AGGIUNGI'),
                            onSubmitted: (value) => _aggiungiElemento(value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _aggiungiElemento(_itemController.text),
                          icon: const Icon(Icons.add_circle, color: Colors.black, size: 32),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // MODIFICA: Rimosso Expanded e adattata la ListView per funzionare dentro lo scroll generico
                    _elementiChecklist.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: Text(
                                "Nessun elemento aggiunto",
                                style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true, // Cruciale dentro SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(), // Disabilita lo scroll interno della lista
                            itemCount: _elementiChecklist.length,
                            itemBuilder: (context, index) {
                              final item = _elementiChecklist[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    item['nome'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      decoration: item['isChecked'] 
                                          ? TextDecoration.lineThrough 
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  value: item['isChecked'],
                                  activeColor: Colors.black,
                                  checkColor: Color.fromRGBO(255, 193, 7, 1),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (bool? valoreNuovo) {
                                    setState(() {
                                      item['isChecked'] = valoreNuovo ?? false;
                                    });
                                  },
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (_itemController.text.trim().isNotEmpty) {
                          _aggiungiElemento(_itemController.text);
                        }

                        String titoloInserito = _titleController.text.trim();
                        if (titoloInserito.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inserisci un titolo per la tua checklist!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (_elementiChecklist.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aggiungi almeno un elemento alla checklist!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context, {
                          'titolo': titoloInserito,
                          'elementi': _elementiChecklist,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(120, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}