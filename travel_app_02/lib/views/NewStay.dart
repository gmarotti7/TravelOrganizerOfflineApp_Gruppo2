import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/models/trip.dart'; // Importato per accedere alle date del viaggio
import 'BottomBar.dart';

class NewStay extends StatefulWidget {
  final Trip? viaggio; // Riceve il viaggio corrente per ricavare i limiti di data

  const NewStay({Key? key, this.viaggio}) : super(key: key);

  @override
  State<NewStay> createState() => _NewStayState();
}

class _NewStayState extends State<NewStay> {
  // Key per il Form
  final _formKey = GlobalKey<FormState>();

  final _titoloController = TextEditingController();
  final _dataController = TextEditingController();
  final _oraController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _costoController = TextEditingController();

  // Funzione per mostrare il calendario (CON LIMITI DI DATA DEL VIAGGIO)
  Future<void> _selezionaData(BuildContext context) async {
    // Impostiamo i limiti di data basandoci sul viaggio (se presente)
    final DateTime dataInizioViaggio = widget.viaggio?.dataInizio ?? DateTime(2000);
    final DateTime dataFineViaggio = widget.viaggio?.dataFine ?? DateTime(2100);

    // Se la data di oggi è fuori dal range del viaggio, usiamo la data inizio come iniziale
    DateTime dataInizialePicker = DateTime.now();
    if (dataInizialePicker.isBefore(dataInizioViaggio) || dataInizialePicker.isAfter(dataFineViaggio)) {
      dataInizialePicker = dataInizioViaggio;
    }

    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: dataInizialePicker,
      firstDate: dataInizioViaggio, // BLOCCO: Non fa selezionare prima del viaggio
      lastDate: dataFineViaggio,     // BLOCCO: Non fa selezionare dopo il viaggio
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Color.fromRGBO(255, 193, 7, 1),
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelezionata != null) {
      String giorno = dataSelezionata.day.toString().padLeft(2, '0');
      String mese = dataSelezionata.month.toString().padLeft(2, '0');
      String anno = dataSelezionata.year.toString();
      setState(() {
        _dataController.text = "$giorno/$mese/$anno";
      });
    }
  }

  // Funzione per mostrare il selettore dell'ora
  Future<void> _selezionaOra(BuildContext context) async {
    final TimeOfDay? oraSelezionata = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.amber,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (oraSelezionata != null) {
      String ore = oraSelezionata.hour.toString().padLeft(2, '0');
      String minuti = oraSelezionata.minute.toString().padLeft(2, '0');
      setState(() {
        _oraController.text = "$ore:$minuti";
      });
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _dataController.dispose();
    _oraController.dispose();
    _descrizioneController.dispose();
    _costoController.dispose();
    super.dispose();
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
          'NUOVA TAPPA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form( // 1. AVVOLTO IN UN WIDGET FORM
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DATA
                const Text('DATA (gg/mm/aaaa)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _dataController,
                  readOnly: true,
                  onTap: () => _selezionaData(context),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Seleziona la data della tappa';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'gg/mm/aaaa',
                    suffixIcon: Icon(Icons.calendar_month, color: Colors.black),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 20),

                // ORA
                const Text('ORA (hh:mm)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _oraController,
                  readOnly: true,
                  onTap: () => _selezionaOra(context),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Seleziona l'ora della tappa";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'hh:mm',
                    suffixIcon: Icon(Icons.access_time, color: Colors.black),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 20),

                // TITOLO
                const Text('TITOLO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _titoloController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci un titolo';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 20),

                // DESCRIZIONE
                const Text('DESCRIZIONE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _descrizioneController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci una descrizione';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 20),

                // COSTO PREVISTO
                const Text('COSTO PREVISTO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _costoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il costo';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 40),

                // CONFERMA
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // 2. CONTROLLO DI VALIDAZIONE DI TUTTI I CAMPI
                      if (_formKey.currentState!.validate()) {
                        final nuovaTappa = Stay(
                          id: DateTime.now().toString(),
                          titolo: _titoloController.text.trim(),
                          data: _dataController.text.trim(),
                          ora: _oraController.text.trim(),
                          descrizione: _descrizioneController.text.trim(),
                          costoPrevisto: double.tryParse(_costoController.text.replaceAll(',', '.')) ?? 0.0,
                        );
                        Navigator.pop(context, nuovaTappa);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('CONFERMA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}