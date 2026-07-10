// lib/views/add_trip.dart
import 'package:flutter/material.dart';

class AddTrip extends StatefulWidget {
  const AddTrip({super.key});

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  // Controller per i campi di testo
  final _titoloController = TextEditingController();
  final _destinazioneController = TextEditingController();
  final _budgetController = TextEditingController();
  final _noteController = TextEditingController();

  // Gestione Date
  DateTime? _dataPartenza;
  DateTime? _dataRitorno;

  // Stato delle Packlist Consigliate
  bool _isMareSpuntato = false;
  bool _isMontagnaSpuntato = false;
  bool _isCittaSpuntato = false;

  // Mappe per tracciare gli elementi spuntati dentro le liste consigliate
  final Map<String, bool> _oggettiMare = {'Crema solare': false, 'Ciabatte': false, 'Costume': false};
  final Map<String, bool> _oggettiMontagna = {'Scarponi': false, 'Giacca a vento': false, 'Borraccia': false};
  final Map<String, bool> _oggettiCitta = {'Mappa': false, 'Scarpe comode': false, 'Powerbank': false};

  // Liste simulate (per tappe e checklist personalizzate che faremo in futuro)
  final List<String> _tappeAggiunte = ['Tappa 1: Hotel Roma', 'Tappa 2: Colosseo'];
  final List<String> _checklistPersonalizzate = ['Lista Farmaci', 'Documenti di viaggio'];

  // Valuta simulata (da recuperare in futuro dal sign_up)
  final String _valutaScelta = '€';

  @override
  void dispose() {
    _titoloController.dispose();
    _destinazioneController.dispose();
    _budgetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Funzione per selezionare il range di date corretta e visibile
Future<void> _selezionaDateRange(BuildContext context) async {
    final DateTime oggi = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      // Impostando 'oggi' come firstDate, l'utente non potrà selezionare date passate
      firstDate: oggi, 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color.fromRGBO(225, 170, 5, 1),    // Giallo ocra per i giorni selezionati
              onPrimary: Colors.black,                    // Testo nero sopra i giorni evidenziati
              surface: Color(0xFF1E1E1E),                 // Sfondo del corpo del calendario
              onSurface: Colors.white,                    // Testo dei giorni futuri in bianco
              onSurfaceVariant: Colors.white24,           // Colore per i giorni passati/disabilitati (grigio opaco)
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Color(0xFF121212),
              headerBackgroundColor: Colors.black,
              headerHeadlineStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              headerHelpStyle: TextStyle(color: Color.fromRGBO(225, 170, 5, 1), fontWeight: FontWeight.bold),
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
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1), // Giallo ocra
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
              // 1. INPUT TITOLO
              _buildTextField(controller: _titoloController, hintText: 'TITOLO'),
              const SizedBox(height: 15),

              // 2. INPUT DESTINAZIONE
              _buildTextField(controller: _destinazioneController, hintText: 'DESTINAZIONE'),
              const SizedBox(height: 15),

              // 3. SELETTORE DATA (DA / A)
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

              // 4. BOTTONE AGGIUNGI TAPPA
              _buildButtonNero(
                testo: 'AGGIUNGI TAPPA',
                onPressed: () {
                  debugPrint("Andiamo alla pagina aggiungi tappa...");
                },
              ),

              // LISTA DELLE TAPPE AGGIUNTE
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
                    children: _tappeAggiunte.map((tappa) => Text('• $tappa', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black))).toList(),
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

              // SEZIONE SELEZIONE PACKLIST
              _buildPacklistCheckbox('MARE', _isMareSpuntato, _oggettiMare, (val) => setState(() => _isMareSpuntato = val!)),
              _buildPacklistCheckbox('MONTAGNA', _isMontagnaSpuntato, _oggettiMontagna, (val) => setState(() => _isMontagnaSpuntato = val!)),
              _buildPacklistCheckbox('CITTÀ', _isCittaSpuntato, _oggettiCitta, (val) => setState(() => _isCittaSpuntato = val!)),

              const SizedBox(height: 25),

              // 5. BOTTONE NUOVA CHECKLIST
              _buildButtonNero(
                testo: 'NUOVA CHECKLIST!',
                onPressed: () {
                  debugPrint("Naviga verso add_checklist.dart");
                },
              ),

              // LISTA DELLE CHECKLIST PERSONALIZZATE
              if (_checklistPersonalizzate.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._checklistPersonalizzate.map((checklist) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black, width: 1.5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(checklist, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                        onPressed: () => debugPrint("Naviga verso recap_check.dart per modificare $checklist"),
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 25),

              // 6. BUDGET PREVISTO
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

              // 7. SEZIONE NOTE
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

              // 8. BOTTONE CONFERMA FINALE
              _buildButtonNero(
                testo: 'CONFERMA',
                onPressed: () {
                  if (_titoloController.text.isNotEmpty && _destinazioneController.text.isNotEmpty) {
                    final nuovoViaggioDati = {
                      'titolo': _titoloController.text,
                      'luogo': _destinazioneController.text,
                      'data': _dataPartenza ?? DateTime.now(),
                    };
                    Navigator.pop(context, nuovoViaggioDati);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
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

  Widget _buildPacklistCheckbox(String titolo, bool isSpuntato, Map<String, bool> mappaOggetti, Function(bool?) onChanged) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black, width: 2)),
          child: CheckboxListTile(
            title: Text(titolo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            value: isSpuntato,
            activeColor: Colors.black,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: onChanged,
          ),
        ),
        if (isSpuntato)
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