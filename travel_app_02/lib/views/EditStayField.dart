import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'BottomBar.dart';
import 'package:travel_app_02/sessione.dart';

class EditStayField extends StatefulWidget {
  const EditStayField({Key? key}) : super(key: key);

  @override
  State<EditStayField> createState() => _EditStayFieldState();
}

class _EditStayFieldState extends State<EditStayField> {
  final _testoController = TextEditingController();
  bool _inizializzato = false;

  final StayController _stayController = StayController();
  DateTime? _dataInizioViaggio;
  DateTime? _dataFineViaggio;

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  Future<void> _selezionaData(BuildContext context) async {
    DateTime primoGiornoValido = _dataInizioViaggio ?? DateTime(2000);
    DateTime ultimoGiornoValido = _dataFineViaggio ?? DateTime(2100);
    
    DateTime dataIniziale = DateTime.now();
    
    if (_testoController.text.isNotEmpty) {
      try {
        final parti = _testoController.text.split('/');
        if (parti.length == 3) {
          dataIniziale = DateTime(int.parse(parti[2]), int.parse(parti[1]), int.parse(parti[0]));
        }
      } catch (_) {}
    }

    if (dataIniziale.isBefore(primoGiornoValido) || dataIniziale.isAfter(ultimoGiornoValido)) {
      dataIniziale = primoGiornoValido;
    }

    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: dataIniziale,
      firstDate: primoGiornoValido,
      lastDate: ultimoGiornoValido,
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

    if (dataSelezionata != null) {
      String giorno = dataSelezionata.day.toString().padLeft(2, '0');
      String mese = dataSelezionata.month.toString().padLeft(2, '0');
      String anno = dataSelezionata.year.toString();
      setState(() {
        _testoController.text = "$giorno/$mese/$anno";
      });
    }
  }

  Future<void> _selezionaOra(BuildContext context) async {
    TimeOfDay oraIniziale = TimeOfDay.now();
    
    if (_testoController.text.isNotEmpty) {
      try {
        final parti = _testoController.text.split(':');
        if (parti.length == 2) {
          oraIniziale = TimeOfDay(hour: int.parse(parti[0]), minute: int.parse(parti[1]));
        }
      } catch (_) {}
    }

    final TimeOfDay? oraSelezionata = await showTimePicker(
      context: context,
      initialTime: oraIniziale,
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
        _testoController.text = "$ore:$minuti";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Stay tappa = args['tappa'];
    final String campo = args['campo'];
    final String label = args['label'];

    if (!_inizializzato) {
      _dataInizioViaggio = args['dataInizioViaggio'];
      _dataFineViaggio = args['dataFineViaggio'];

      switch (campo) {
        case 'titolo':
          _testoController.text = tappa.titolo;
          break;
        case 'data':
          _testoController.text = tappa.data;
          break;
        case 'ora':
          _testoController.text = tappa.ora;
          break;
        case 'descrizione':
          _testoController.text = tappa.descrizione ?? '';
          break;
        case 'costoPrevisto':
          _testoController.text = tappa.costoPrevisto.toString();
          break;
      }
      _inizializzato = true;
    }

    final bool isNumero = campo == 'costoPrevisto';
    final bool isDescrizione = campo == 'descrizione';
    final bool isData = campo == 'data';
    final bool isOra = campo == 'ora';
    
    final bool isSolaLettura = isData || isOra;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 193, 7, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 193, 7, 1),
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
              isNumero ? '${label.toUpperCase()} (${Sessione.valutaAttuale})' : label.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _testoController,
              maxLines: isDescrizione ? 4 : 1,
              keyboardType: isNumero ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              inputFormatters: isNumero ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] : null,
              
              readOnly: isSolaLettura,
              onTap: () {
                if (isData) _selezionaData(context);
                if (isOra) _selezionaOra(context);
              },
              
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                suffixText: isNumero ? Sessione.valutaAttuale : null, // <-- MOSTRA VALUTA NEL CAMPO SOLO PER I NUMERI
                suffixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                suffixIcon: isData 
                    ? const Icon(Icons.calendar_month, color: Colors.black) 
                    : isOra 
                        ? const Icon(Icons.access_time, color: Colors.black) 
                        : null,
                        
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final dynamic valoreDaSalvare =
                      isNumero ? (double.tryParse(_testoController.text.replaceAll(',', '.')) ?? tappa.costoPrevisto) : _testoController.text;

                  try {
                    await _stayController.aggiornaCampoTappa(tappa.id, campo, valoreDaSalvare);
                    if (context.mounted) {
                      Navigator.pop(context, {'campo': campo, 'valore': valoreDaSalvare});
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