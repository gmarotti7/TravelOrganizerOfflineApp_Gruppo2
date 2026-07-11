// lib/views/add_check.dart
import 'package:flutter/material.dart';

class AddCheck extends StatefulWidget {
  const AddCheck({super.key});

  @override
  State<AddCheck> createState() => _AddCheckState();
}

class _AddCheckState extends State<AddCheck> {
  final _titleController = TextEditingController();
  final _itemController = TextEditingController();

  // Lista dinamica che conterrà gli elementi della checklist
  final List<Map<String, dynamic>> _elementiChecklist = [];

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
        'isChecked': false, // Di base l'elemento non è completato
      });
    });

    _itemController.clear(); // Svuota la casella di testo
  }

  // Funzione di utilità per mantenere lo stile dei campi di testo neri coordinati
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
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1), // Giallo ocra coordinato
      body: SafeArea(
        child: Stack(
          children: [
            // 1. FRECCIA IN ALTO A SINISTRA
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pop(context); // Torna indietro senza salvare
                },
              ),
            ),

            // Contenuto Principale della pagina scorribile per evitare crash di spazio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // Spazio per la freccia

                  // 2. SCRITTA "LA TUA CHECKLIST:"
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

                  // 3. CASELLA DI TESTO TITOLO
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    cursorColor: Colors.white,
                    decoration: _buildInputDecoration('TITOLO'),
                  ),

                  const SizedBox(height: 35),

                  // 4. SCRITTA "COSA VUOI AGGIUNGERE?"
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

                  // 5. CASELLA DI TESTO AGGIUNGI (Rileva l'invio sulla tastiera)
                  TextField(
                    controller: _itemController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    cursorColor: Colors.white,
                    decoration: _buildInputDecoration('AGGIUNGI'),
                    onSubmitted: (value) => _aggiungiElemento(value), // Aggiunge premendo Invio
                  ),

                  const SizedBox(height: 25),

                  // 6. AREA LISTA DEGLI ELEMENTI AGGIUNTI (Dinamica)
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
                                          : TextDecoration.none, // Barra il testo se completato
                                    ),
                                  ),
                                  value: item['isChecked'],
                                  activeColor: Colors.black,
                                  checkColor: const Color.fromRGBO(225, 170, 5, 1),
                                  controlAffinity: ListTileControlAffinity.leading, // Mette la casella a sinistra come in image_4198c7.png
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

                  // 7. BOTTONE OK DI CONFERMA FINALE
                  ElevatedButton(
                    // Assicurati che nel bottone OK ci sia questo:
                    onPressed: () {
                    String titoloInserito = _titleController.text.trim();
                      if (titoloInserito.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inserisci un titolo per la tua checklist!')),
                        );
                      return;
                    }

  // Questo è fondamentale: passa la mappa indietro
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