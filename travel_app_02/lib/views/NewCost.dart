import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/trip.dart';
import 'BottomBar.dart';

class NewCost extends StatefulWidget {
  const NewCost({Key? key}) : super(key: key);

  @override
  State<NewCost> createState() => _NewCostState();
}

class _NewCostState extends State<NewCost> {
  final _formKey = GlobalKey<FormState>();

  final _titoloController = TextEditingController();
  final _costoController = TextEditingController();
  final _dataController = TextEditingController();
  final _oraController = TextEditingController();
  final _descrizioneController = TextEditingController();
  String? _categoriaSelezionata;
  final _viaggioAssociatoController = TextEditingController();
  final _attivitaAssociataController = TextEditingController();
  Trip? _viaggioSelezionato;
  String? _statoSelezionato;
  String? _metodoPagamento;
  String _valutaSelezionata = 'EUR';

  String? _erroreOra;

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _viaggioSelezionato?.dataInizio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _viaggioSelezionato?.dataFine ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.amber,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
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

  void _validaData(String valore) {
    if (valore.isEmpty) {
      return;
    }

    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(valore)) {
      return;
    }

    final parti = valore.split('/');
    final giorno = int.tryParse(parti[0]) ?? 0;
    final mese = int.tryParse(parti[1]) ?? 0;
    final anno = int.tryParse(parti[2]) ?? 0;

    if (mese < 1 || mese > 12) {
      return;
    }

    int maxGiorni = 31;
    if (mese == 4 || mese == 6 || mese == 9 || mese == 11) {
      maxGiorni = 30;
    } else if (mese == 2) {
      final bisestile = (anno % 4 == 0 && anno % 100 != 0) || (anno % 400 == 0);
      maxGiorni = bisestile ? 29 : 28;
    }

    if (giorno < 1 || giorno > maxGiorni) {
      return;
    }
  }

  Future<void> _selezionaOra(BuildContext context) async {
    final TimeOfDay? ora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (ora != null) setState(() => _oraController.text = "${ora.hour.toString().padLeft(2, '0')}:${ora.minute.toString().padLeft(2, '0')}");
  }

  void _validaOra(String valore) {
    if (valore.isEmpty) {
      setState(() => _erroreOra = null);
      return;
    }

    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(valore)) {
      setState(() => _erroreOra = 'Ora non valida');
      return;
    }

    final parti = valore.split(':');
    final ore = int.tryParse(parti[0]) ?? -1;
    final minuti = int.tryParse(parti[1]) ?? -1;

    if (ore < 0 || ore > 23 || minuti < 0 || minuti > 59) {
      setState(() => _erroreOra = 'Ora non valida');
      return;
    }

    setState(() => _erroreOra = null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Trip) {
      setState(() {
        _viaggioSelezionato = args;
        _viaggioAssociatoController.text = args.titolo;
      });
    }
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'NUOVA SPESA',
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
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  const Text('STATO: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statoSelezionato,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                      hint: const Text('. . .'),
                      validator: (valore) => valore == null ? 'Obbligatorio' : null,
                      items: [
                        DropdownMenuItem(
                          value: 'Da pagare',
                          child: Row(children: const [Icon(Icons.circle, color: Colors.red, size: 14), SizedBox(width: 8), Text('Da pagare')]),
                        ),
                        DropdownMenuItem(
                          value: 'Pagata',
                          child: Row(children: const [Icon(Icons.circle, color: Colors.green, size: 14), SizedBox(width: 8), Text('Pagata')]),
                        ),
                      ],
                      onChanged: (valore) {
                        setState(() => _statoSelezionato = valore);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              const Text('DATA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dataController,
                keyboardType: TextInputType.datetime,
                validator: (valore) {
                  if (valore == null || valore.trim().isEmpty) {
                    return 'Seleziona la data della spesa';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(valore.trim())) {
                    return 'Data non valida (gg/mm/aaaa)';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                  hintText: "gg/mm/aaaa",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.black),
                    onPressed: () => _selezionaData(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('ORA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              TextField(
                controller: _oraController,
                readOnly: true,
                onTap: () => _selezionaOra(context),
                decoration: InputDecoration(
                  hintText: 'HH:MM',
                  errorText: _erroreOra,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              const Text('TITOLO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _titoloController,
                validator: (valore) {
                  if (valore == null || valore.trim().isEmpty) {
                    return 'Inserisci un titolo';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              const Text('DESCRIZIONE:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _descrizioneController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text('METODO\nPAGAMENTO: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _metodoPagamento,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                      hint: const Text('. . .'),
                      validator: (valore) => valore == null ? 'Obbligatorio' : null,
                      items: const [
                        DropdownMenuItem(value: 'Contanti', child: Text('Contanti')),
                        DropdownMenuItem(value: 'Carta di credito', child: Text('Carta di credito')),
                        DropdownMenuItem(value: 'Carta di debito', child: Text('Carta di debito')),
                      ],
                      onChanged: (valore) {
                        setState(() => _metodoPagamento = valore);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text('CATEGORIA: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSelezionata,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                      ),
                      hint: const Text('. . .'),
                      validator: (valore) => valore == null ? 'Obbligatorio' : null,
                      items: const [
                        DropdownMenuItem(value: 'Cibo e Bevande', child: Text('Cibo e Bevande')),
                        DropdownMenuItem(value: 'Trasporti', child: Text('Trasporti')),
                        DropdownMenuItem(value: 'Alloggio', child: Text('Alloggio')),
                        DropdownMenuItem(value: 'Svago e Tour', child: Text('Svago e Tour')),
                        DropdownMenuItem(value: 'Altro', child: Text('Altro')),
                      ],
                      onChanged: (valore) {
                        setState(() => _categoriaSelezionata = valore);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('VIAGGIO ASSOCIATO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _viaggioAssociatoController,
                readOnly: true,
                enabled: false,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              const Text('ATTIVITÀ ASSOCIATA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              TextField(
                controller: _attivitaAssociataController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text('COSTO ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _costoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (valore) {
                        if (valore == null || valore.trim().isEmpty) {
                          return 'Inserisci il costo';
                        }
                        final numero = double.tryParse(valore.replaceAll(',', '.'));
                        if (numero == null || numero <= 0) {
                          return 'Costo non valido';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.zero),
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3), borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: DropdownButton<String>(
                      value: _valutaSelezionata,
                      underline: const SizedBox(),
                      items: ['EUR', 'USD', 'GBP', 'JPY', 'CHF']
                          .map((valuta) => DropdownMenuItem(
                                value: valuta,
                                child: Text(valuta, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (valore) {
                        if (valore != null) {
                          setState(() => _valutaSelezionata = valore);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final formValido = _formKey.currentState!.validate();
                    final erroreDropdown = _statoSelezionato == null ||
                        _metodoPagamento == null ||
                        _categoriaSelezionata == null;

                    if (!formValido || erroreDropdown) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compila tutti i campi obbligatori prima di confermare'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final nuovaSpesa = Expense(
                      id: DateTime.now().toString(),
                      titolo: _titoloController.text.trim(),
                      importo: double.parse(_costoController.text.replaceAll(',', '.')),
                      stato: _statoSelezionato!,
                      data: _dataController.text.trim(),
                      descrizione: _descrizioneController.text,
                      metodoPagamento: _metodoPagamento!,
                      categoria: _categoriaSelezionata!,
                      viaggioAssociato: _viaggioAssociatoController.text.isEmpty ? 'Nessuno' : _viaggioAssociatoController.text,
                      attivitaAssociata: _attivitaAssociataController.text.isEmpty ? 'Nessuna' : _attivitaAssociataController.text,
                      valuta: _valutaSelezionata,
                    );
                    Navigator.pop(context, nuovaSpesa);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
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