import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/controllers/profile_controller.dart';
import 'BottomBar.dart';

class EditProfileField extends StatefulWidget {
  const EditProfileField({Key? key}) : super(key: key);

  @override
  State<EditProfileField> createState() => _EditProfileFieldState();
}

class _EditProfileFieldState extends State<EditProfileField> {
  final _testoController = TextEditingController();
  bool _inizializzato = false;
  String? _valutaSelezionata;

  final List<String> _valuteDisponibili = const ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];

  final ProfileController _profileController = ProfileController();

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Utente utente = args['utente'];
    final String campo = args['campo'];
    final String label = args['label'];

    if (!_inizializzato) {
      switch (campo) {
        case 'username':
          _testoController.text = utente.username;
          break;
        case 'email':
          _testoController.text = utente.email;
          break;
        case 'eta':
          _testoController.text = utente.eta.toString();
          break;
        case 'valuta':
          _testoController.text = utente.valuta;
          _valutaSelezionata = _valuteDisponibili.contains(utente.valuta) ? utente.valuta : _valuteDisponibili.first;
          break;
        case 'password':
          _testoController.text = '';
          break;
      }
      _inizializzato = true;
    }

    final bool isNumero = campo == 'eta';
    final bool isPassword = campo == 'password';
    final bool isValuta = campo == 'valuta';

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

            isValuta
                ? DropdownButtonFormField<String>(
                    value: _valutaSelezionata,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    ),
                    items: _valuteDisponibili
                        .map((valuta) => DropdownMenuItem(value: valuta, child: Text(valuta)))
                        .toList(),
                    onChanged: (valore) {
                      setState(() {
                        _valutaSelezionata = valore;
                        _testoController.text = valore ?? '';
                      });
                    },
                  )
                : TextField(
                    controller: _testoController,
                    obscureText: isPassword,
                    keyboardType: isNumero ? TextInputType.number : TextInputType.text,
                    inputFormatters: isNumero ? [FilteringTextInputFormatter.digitsOnly] : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: isPassword ? 'Nuova password' : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.zero),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
                    ),
                  ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final String testo = _testoController.text.trim();

                  if (testo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Il campo non può essere vuoto.')),
                    );
                    return;
                  }

                  dynamic nuovoValore;
                  if (isNumero) {
                    nuovoValore = int.tryParse(testo);
                    if (nuovoValore == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inserisci un numero valido.')),
                      );
                      return;
                    }
                  } else {
                    nuovoValore = testo;
                  }

                  try {
                    await _profileController.aggiornaCampoUtente(utente.id!, campo, nuovoValore);
                    if (context.mounted) {
                      // Per la password non rimandiamo indietro il valore in chiaro.
                      Navigator.pop(context, {'campo': campo, 'valore': isPassword ? null : nuovoValore});
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