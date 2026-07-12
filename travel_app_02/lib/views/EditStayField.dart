import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/controllers/stay_controller.dart';
import 'BottomBar.dart';

class EditStayField extends StatefulWidget {
  const EditStayField({Key? key}) : super(key: key);

  @override
  State<EditStayField> createState() => _EditStayFieldState();
}

class _EditStayFieldState extends State<EditStayField> {
  final _testoController = TextEditingController();
  bool _inizializzato = false;

  final StayController _stayController = StayController();

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Stay tappa = args['tappa'];
    final String campo = args['campo'];
    final String label = args['label'];

    if (!_inizializzato) {
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

            TextField(
              controller: _testoController,
              maxLines: isDescrizione ? 4 : 1,
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
                  final dynamic valoreDaSalvare =
                      isNumero ? (double.tryParse(_testoController.text.replaceAll(',', '.')) ?? tappa.costoPrevisto) : _testoController.text;

                  try {
                    await _stayController.aggiornaCampoTappa(tappa.id, campo, valoreDaSalvare);
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