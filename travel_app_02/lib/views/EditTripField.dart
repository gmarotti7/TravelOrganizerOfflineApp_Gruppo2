import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/controllers/trip_controller.dart';
import 'BottomBar.dart';

class EditTripField extends StatefulWidget {
  const EditTripField({Key? key}) : super(key: key);

  @override
  State<EditTripField> createState() => _EditTripFieldState();
}

class _EditTripFieldState extends State<EditTripField> {
  final _testoController = TextEditingController();
  DateTime? _dataSelezionata;
  bool _inizializzato = false;

  final TripController _tripController = TripController();

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Trip trip = args['trip'];
    final String campo = args['campo'];
    final String label = args['label'];

    if (!_inizializzato) {
      switch (campo) {
        case 'titolo':
          _testoController.text = trip.titolo;
          break;
        case 'luogo':
          _testoController.text = trip.luogo;
          break;
        case 'budgetPrevisto':
          _testoController.text = trip.budgetPrevisto.toString();
          break;
        case 'dataInizio':
          _dataSelezionata = trip.dataInizio;
          break;
        case 'dataFine':
          _dataSelezionata = trip.dataFine;
          break;
      }
      _inizializzato = true;
    }

    final bool isData = campo == 'dataInizio' || campo == 'dataFine';
    final bool isNumero = campo == 'budgetPrevisto';

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
        title: Text(
          'MODIFICA ${label.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),

            if (isData)
              InkWell(
                onTap: () async {
                  final scelta = await showDatePicker(
                    context: context,
                    initialDate: _dataSelezionata ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                            onPrimary: Color.fromRGBO(255, 193, 7, 1),
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (scelta != null) {
                    setState(() => _dataSelezionata = scelta);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dataSelezionata == null
                              ? 'Seleziona data'
                              : '${_dataSelezionata!.day.toString().padLeft(2, '0')}/${_dataSelezionata!.month.toString().padLeft(2, '0')}/${_dataSelezionata!.year}',
                        ),
                      ),
                      const Icon(Icons.calendar_month, color: Colors.black),
                    ],
                  ),
                ),
              )
            else
              TextField(
                controller: _testoController,
                keyboardType: isNumero ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                inputFormatters: isNumero ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] : null,
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

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  dynamic nuovoValore;
                  if (isData) {
                    nuovoValore = _dataSelezionata ?? trip.dataInizio;
                  } else if (isNumero) {
                    nuovoValore = double.tryParse(_testoController.text.replaceAll(',', '.')) ?? trip.budgetPrevisto;
                  } else {
                    nuovoValore = _testoController.text;
                  }

                  final valoreDaSalvare = isData ? (nuovoValore as DateTime).toIso8601String() : nuovoValore;

                  try {
                    await _tripController.aggiornaCampoViaggio(trip.id, campo, valoreDaSalvare);
                    if (context.mounted) {
                      Navigator.pop(context, {'campo': campo, 'valore': nuovoValore});
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Errore durante il salvataggio: $e')),
                      );
                    }
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
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}