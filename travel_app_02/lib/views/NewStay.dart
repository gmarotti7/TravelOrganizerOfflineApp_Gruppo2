import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/stay.dart';
import 'BottomBar.dart';

class NewStay extends StatefulWidget {
  const NewStay({Key? key}) : super(key: key);

  @override
  State<NewStay> createState() => _NewStayState();
}

class _NewStayState extends State<NewStay> {
  final _titoloController = TextEditingController();
  final _dataController = TextEditingController();
  final _oraController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _costoController = TextEditingController();

  // Funzione per mostrare il calendario (stesso stile di NewCost)
  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.amber,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DATA
              const Text('DATA (gg/mm/aaaa)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _dataController,
                readOnly: true,
                onTap: () => _selezionaData(context),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'gg/mm/aaaa',
                  suffixIcon: const Icon(Icons.calendar_month, color: Colors.black),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // ORA
              const Text('ORA (hh:mm)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _oraController,
                readOnly: true,
                onTap: () => _selezionaOra(context),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'hh:mm',
                  suffixIcon: const Icon(Icons.access_time, color: Colors.black),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // TITOLO
              const Text('TITOLO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _titoloController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // DESCRIZIONE
              const Text('DESCRIZIONE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _descrizioneController,
                maxLines: 4,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              // COSTO PREVISTO
              const Text('COSTO PREVISTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _costoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 40),

              // CONFERMA
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final nuovaTappa = Stay(
                      id: DateTime.now().toString(),
                      titolo: _titoloController.text.isEmpty ? 'Nuova Tappa' : _titoloController.text,
                      data: _dataController.text,
                      ora: _oraController.text,
                      descrizione: _descrizioneController.text,
                      costoPrevisto: double.tryParse(_costoController.text.replaceAll(',', '.')) ?? 0.0,
                    );
                    Navigator.pop(context, nuovaTappa);
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
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}