import 'package:flutter/material.dart';
import 'Add_check.dart';
import 'NewStay.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/controllers/trip_controller.dart';
import 'package:travel_app_02/sessione.dart';

class AddTrip extends StatefulWidget {
  const AddTrip({super.key});

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final _titoloController = TextEditingController();
  final _destinazioneController = TextEditingController();
  final _budgetController = TextEditingController();
  final _noteController = TextEditingController();
  final TripController _viaggioController = TripController();

  DateTime? _dataPartenza;
  DateTime? _dataRitorno;

  String? _packlistSelezionata;

  final Map<String, bool> _oggettiMare = {'Crema solare': true, 'Ciabatte': true, 'Costume': true};
  final Map<String, bool> _oggettiMontagna = {'Scarponi': true, 'Giacca a vento': true, 'Borraccia': true};
  final Map<String, bool> _oggettiCitta = {'Mappa': true, 'Scarpe comode': true, 'Powerbank': true};

  Map<String, bool> _mappaPerTitolo(String titolo) {
    switch (titolo) {
      case 'MARE':
        return _oggettiMare;
      case 'MONTAGNA':
        return _oggettiMontagna;
      case 'CITTÀ':
        return _oggettiCitta;
      default:
        return {};
    }
  }

  final List<Stay> _tappeAggiunte = [];
  final List<Map<String, dynamic>> _checklistPersonalizzate = [];

  late final String _valutaScelta = Sessione.valutaAttuale;

  @override
  void dispose() {
    _titoloController.dispose();
    _destinazioneController.dispose();
    _budgetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _apriAggiungiTappa() async {
    if (_dataPartenza == null || _dataRitorno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona prima le date del viaggio!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viaggioTemporaneo = Trip(
      id: '',
      titolo: _titoloController.text,
      luogo: _destinazioneController.text,
      dataInizio: _dataPartenza!,
      dataFine: _dataRitorno!,
      budgetPrevisto: 0,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewStay(viaggio: viaggioTemporaneo)),
    );

    if (result != null && result is Stay) {
      setState(() {
        _tappeAggiunte.add(result);
      });
    }
  }

  Future<void> _apriAggiungiChecklist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCheck()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _checklistPersonalizzate.add(result);
      });
    }
  }

  Future<void> _modificaChecklist(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCheck(
          checklistIniziale: _checklistPersonalizzate[index],
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _checklistPersonalizzate[index] = result;
      });
    }
  }

  Future<void> _selezionaDateRange(BuildContext context) async {
    final DateTime oggi = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: oggi,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color.fromRGBO(255, 193, 7, 1),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white24,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Color(0xFF121212),
              headerBackgroundColor: Colors.black,
              headerHeadlineStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              headerHelpStyle: TextStyle(color: Color.fromRGBO(255, 193, 7, 1), fontWeight: FontWeight.bold),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataPartenza = picked.start;
        _dataRitorno = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 193, 7, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ORGANIZZA IL TUO VIAGGIO',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(controller: _titoloController, hintText: 'TITOLO'),
              const SizedBox(height: 15),

              _buildTextField(
                controller: _destinazioneController, 
                hintText: 'DESTINAZIONE',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),

              InkWell(
                onTap: () => _selezionaDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    _dataPartenza == null || _dataRitorno == null
                        ? 'DA: GG/MM/AAAA  •  A: GG/MM/AAAA'
                        : 'DA: ${_dataPartenza!.day}/${_dataPartenza!.month}/${_dataPartenza!.year}  •  A: ${_dataRitorno!.day}/${_dataRitorno!.month}/${_dataRitorno!.year}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              _buildButtonNero(
                testo: 'AGGIUNGI TAPPA',
                onPressed: _apriAggiungiTappa,
              ),

              if (_tappeAggiunte.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _tappeAggiunte.asMap().entries.map((entry) {
                      final tappa = entry.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('• ${tappa.titolo}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54, size: 18),
                            onPressed: () => setState(() => _tappeAggiunte.removeAt(entry.key)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'PACKLIST CONSIGLIATE:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 15),

              _buildPacklistRadio('MARE', _oggettiMare),
              _buildPacklistRadio('MONTAGNA', _oggettiMontagna),
              _buildPacklistRadio('CITTÀ', _oggettiCitta),

              const SizedBox(height: 25),

              _buildButtonNero(
                testo: 'NUOVA CHECKLIST',
                onPressed: _apriAggiungiChecklist,
              ),

              if (_checklistPersonalizzate.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._checklistPersonalizzate.asMap().entries.map((entry) {
                  int index = entry.key;
                  var checklist = entry.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black, width: 1.5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(checklist['titolo'] ?? 'Senza Titolo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                          onPressed: () => _modificaChecklist(index),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 25),

              Row(
                children: [
                  const Text('BUDGET PREVISTO: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          suffixText: _valutaScelta,
                          suffixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.black, width: 2)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                height: 120,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'NOTE:',
                    hintStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildButtonNero(
                testo: 'CONFERMA',
                onPressed: () async {
                  if (_titoloController.text.isNotEmpty &&
                      _destinazioneController.text.isNotEmpty &&
                      _dataPartenza != null &&
                      _dataRitorno != null) {

                    final String titoloNuovo = _titoloController.text.trim().toLowerCase();
                    final int idUtente = Sessione.idUtenteAttuale ?? 1;

                    try {
                      // Recuperiamo tutti i viaggi salvati dell'utente attuale
                      final viaggiEsistenti = await _viaggioController.caricaViaggiUtente(idUtente);
                      
                      // 1. CONTROLLO FILTRO TITOLI DUPLICATI
                      final bool titoloGiaPresente = viaggiEsistenti.any(
                        (v) => v.titolo.trim().toLowerCase() == titoloNuovo
                      );

                      if (titoloGiaPresente) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Esiste già un viaggio con questo titolo! Scegline un altro.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; 
                      }

                      // 2. CONTROLLO FILTRO SOVRAPPOSIZIONE DATE (Coincidenti o comprese)
                      // Normalizziamo le nuove date scelte (senza ore/minuti)
                      final DateTime pNuova = DateTime(_dataPartenza!.year, _dataPartenza!.month, _dataPartenza!.day);
                      final DateTime rNuova = DateTime(_dataRitorno!.year, _dataRitorno!.month, _dataRitorno!.day);

                      final bool dateSovrapposte = viaggiEsistenti.any((v) {
                        final DateTime pEsistente = DateTime(v.dataInizio.year, v.dataInizio.month, v.dataInizio.day);
                        final DateTime rEsistente = DateTime(v.dataFine.year, v.dataFine.month, v.dataFine.day);

                        // Formula matematica di sovrapposizione: inizioA <= fineB E fineA >= inizioB
                        return !pNuova.isAfter(rEsistente) && !rNuova.isBefore(pEsistente);
                      });

                      if (dateSovrapposte) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attenzione! Le date si sovrappongono con un altro viaggio già pianificato.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Blocca il salvataggio
                      }

                    } catch (e) {
                      debugPrint("Errore controlli DB: $e");
                    }

                    String? packlistTitolo;
                    List<Map<String, dynamic>>? packlistElementi;
                    if (_packlistSelezionata != null) {
                      final mappaOggetti = _mappaPerTitolo(_packlistSelezionata!);
                      packlistTitolo = _packlistSelezionata;
                      packlistElementi = mappaOggetti.entries
                          .map((e) => {'nome': e.key, 'isChecked': e.value})
                          .toList();
                    }

                    String? checklistTitolo;
                    List<Map<String, dynamic>>? checklistElementi;
                    if (_checklistPersonalizzate.isNotEmpty) {
                      final prima = _checklistPersonalizzate.first;
                      checklistTitolo = prima['titolo'] as String?;
                      checklistElementi = prima['elementi'] != null
                          ? List<Map<String, dynamic>>.from(prima['elementi'])
                          : [];
                    }

                    final nuovoViaggio = Trip(
                      id: '',
                      titolo: _titoloController.text,
                      luogo: _destinazioneController.text,
                      dataInizio: _dataPartenza!,
                      dataFine: _dataRitorno!,
                      budgetPrevisto: double.tryParse(_budgetController.text.replaceAll(',', '.')) ?? 0.0,
                    );

                    final risultato = {
                      'viaggio': nuovoViaggio,
                      'tappe': _tappeAggiunte,
                      if (packlistTitolo != null) 'packlist': packlistTitolo,
                      if (packlistElementi != null) 'packlistItems': packlistElementi,
                      if (checklistTitolo != null) 'checklist': checklistTitolo,
                      if (checklistElementi != null) 'checklistItems': checklistElementi,
                    };

                    if (!context.mounted) return;
                    Navigator.pop(context, risultato);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compila titolo, destinazione e scegli le date!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.black, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
      ),
    );
  }

  Widget _buildButtonNero({required String testo, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(testo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
    );
  }

  Widget _buildPacklistRadio(String titolo, Map<String, bool> mappaOggetti) {
    final bool isSelezionata = _packlistSelezionata == titolo;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black, width: 2)),
          child: RadioListTile<String>(
            title: Text(titolo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            value: titolo,
            groupValue: _packlistSelezionata,
            activeColor: Colors.black,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _packlistSelezionata = isSelezionata ? null : val),
          ),
        ),
        if (isSelezionata)
          Container(
            height: 110,
            margin: const EdgeInsets.only(left: 16, bottom: 8, right: 4),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(5)),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: mappaOggetti.keys.map((oggetto) {
                  return CheckboxListTile(
                    title: Text(oggetto, style: const TextStyle(fontSize: 14, color: Colors.black)),
                    value: mappaOggetti[oggetto],
                    activeColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    onChanged: (bool? sicuro) {
                      setState(() {
                        mappaOggetti[oggetto] = sicuro!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}