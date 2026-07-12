import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/controllers/cost_controller.dart';
import 'BottomBar.dart';

class EditCostField extends StatefulWidget {
  const EditCostField({Key? key}) : super(key: key);

  @override
  State<EditCostField> createState() => _EditCostFieldState();
}

class _EditCostFieldState extends State<EditCostField> {
  final _testoController = TextEditingController();
  String? _valoreDropdown;
  bool _inizializzato = false;
  final CostController _costController = CostController();

  static const _campiConDropdown = {
    'categoria': ['Cibo e Bevande', 'Trasporti', 'Alloggio', 'Svago e Tour', 'Altro'],
    'metodoPagamento': ['Contanti', 'Carta di credito', 'Carta di debito'],
    'valuta': ['EUR', 'USD', 'GBP', 'JPY', 'CHF'],
  };

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Expense spesa = args['spesa'];
    final String campo = args['campo'];
    final String label = args['label'];

    final bool isDropdown = _campiConDropdown.containsKey(campo);
    final bool isNumero = campo == 'importo';

    if (!_inizializzato) {
      switch (campo) {
        case 'titolo':
          _testoController.text = spesa.titolo;
          break;
        case 'importo':
          _testoController.text = spesa.importo.toString();
          break;
        case 'stato':
          _testoController.text = spesa.stato ?? '';
          break;
        case 'data':
          _testoController.text = spesa.data ?? '';
          break;
        case 'descrizione':
          _testoController.text = spesa.descrizione ?? '';
          break;
        case 'viaggioAssociato':
          _testoController.text = spesa.viaggioAssociato ?? '';
          break;
        case 'attivitaAssociata':
          _testoController.text = spesa.attivitaAssociata ?? '';
          break;
        case 'categoria':
          _valoreDropdown = spesa.categoria;
          break;
        case 'metodoPagamento':
          _valoreDropdown = spesa.metodoPagamento;
          break;
        case 'valuta':
          _valoreDropdown = spesa.valuta ?? 'EUR';
          break;
      }
      _inizializzato = true;
    }

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

            if (isDropdown)
              DropdownButtonFormField<String>(
                value: _valoreDropdown,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3)),
                ),
                items: _campiConDropdown[campo]!
                    .map((valore) => DropdownMenuItem(value: valore, child: Text(valore)))
                    .toList(),
                onChanged: (valore) => setState(() => _valoreDropdown = valore),
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
                  final dynamic nuovoValore;
                  if (isDropdown) {
                    nuovoValore = _valoreDropdown;
                  } else if (isNumero) {
                    nuovoValore = double.tryParse(_testoController.text.replaceAll(',', '.')) ?? spesa.importo;
                  } else {
                    nuovoValore = _testoController.text;
                  }

                  try {
                    await _costController.aggiornaCampoSpesa(spesa.id, campo, nuovoValore);
                    if (context.mounted) {
                      Navigator.pop(context, true);
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