// lib/views/add_check.dart
import 'package:flutter/material.dart';

class AddCheck extends StatefulWidget {
  // MODIFICA: Aggiunto parametro per ricevere i dati da modificare
  final Map<String, dynamic>? checklistIniziale;

  const AddCheck({super.key, this.checklistIniziale});

  @override
  State<AddCheck> createState() => _AddCheckState();
}

class _AddCheckState extends State<AddCheck> {
  final _titleController = TextEditingController();
  final _itemController = TextEditingController();

  // Lista dinamica che conterrà gli elementi della checklist
  final List<Map<String, dynamic>> _elementiChecklist = [];

  @override
  void initState() {
    super.initState();
    // MODIFICA: Se riceviamo dati in ingresso, li carichiamo nei campi
    if (widget.checklistIniziale != null) {
      _titleController.text = widget.checklistIniziale!['titolo'] ?? '';
      
      // Carichiamo la lista degli elementi se presente
      if (widget.checklistIniziale!.containsKey('elementi')) {
        setState(() {
          _elementiChecklist.addAll(
              List<Map<String, dynamic>>.from(widget.checklistIniziale!['elementi'])
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  // Funzione per aggiungere un elemento quando l'utente preme invio
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
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1),
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

                  TextField(
                    controller: _itemController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    cursorColor: Colors.white,
                    decoration: _buildInputDecoration('AGGIUNGI'),
                    onSubmitted: (value) => _aggiungiElemento(value),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: _elementiChecklist.isEmpty
                        ? const Center(
                            child: Text(
                              "Nessun elemento aggiunto",
                              style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
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
                                  checkColor: const Color.fromRGBO(225, 170, 5, 1),
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
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      String titoloInserito = _titleController.text.trim();
                      if (titoloInserito.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inserisci un titolo per la tua checklist!')),
                        );
                        return;
                      }

                      // Passa la mappa aggiornata indietro a AddTrip
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
          ],
        ),
      ),
    );
  }
}