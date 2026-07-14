// lib/views/sign_up.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/controllers/auth_controller.dart';
import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/route.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app_02/sessione.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  // Controller per catturare il testo inserito nei campi
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variabili per la gestione dinamica degli errori della UI
  String? _emailError;
  String? _passwordError;
  
  // Variabile per monitorare la presenza della @ in tempo reale
  bool _hasAtSymbol = false;
  bool _isCaricamento = false;
  
  // Variabile per la valuta selezionata
  String _selectedCurrency = 'EUR';

  // Lista delle valute principali
  final List<String> _currencies = ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];

  File? _immagineSelezionata;
  final ImagePicker _picker = ImagePicker();

  Future<void> _scegliImmagine(ImageSource sorgente) async {
    final XFile? immagine = await _picker.pickImage(source: sorgente);
    
    if (immagine != null) {
      setState(() {
        _immagineSelezionata = File(immagine.path);
      });
    }
  }

  void _mostraMenuSceltaFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.amber),
              title: const Text('Scegli dalla Galleria', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _scegliImmagine(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: const Text('Scatta una Foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _scegliImmagine(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Funzione di utilità per creare lo stile uniforme dei TextField neri
  InputDecoration _buildInputDecoration(String hintText, {String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      errorText: errorText,
      errorStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 13, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1),
      ),
    );
  }

  // Funzione che esegue le verifiche grafiche prima di salvare
  bool _validaCampi() {
    setState(() {
      // Verifica della chiocciola @ nella mail al click del bottone
      if (!_emailController.text.contains('@')) {
        _emailError = 'La mail deve contenere una @';
      } else {
        _emailError = null;
      }

      // Verifica della lunghezza della password (max 8 caratteri)
      if (_passwordController.text.length > 8) {
        _passwordError = 'Massimo 8 caratteri consentiti';
      } else {
        _passwordError = null;
      }
    });

    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 193, 7, 1), // Giallo ocra
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            // Chiudi la tastiera prima del pop
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), // Evita sovrapposizioni con la freccia

                      // Titolo in alto al centro
                      const Text(
                        'INSERISCI I TUOI DATI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // --- WIDGET FOTO PROFILO ---
                      GestureDetector(
                        onTap: _mostraMenuSceltaFoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.black,
                              backgroundImage: _immagineSelezionata != null 
                                  ? FileImage(_immagineSelezionata!) 
                                  : null,
                              child: _immagineSelezionata == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.white54)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30), // Spazio prima dell'username

                      // Campo USERNAME
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _buildInputDecoration('USERNAME'),
                      ),
                      
                      const SizedBox(height: 15),

                      // Campo EMAIL
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _buildInputDecoration('EMAIL', errorText: _emailError),
                        onChanged: (text) {
                          setState(() {
                            _hasAtSymbol = text.contains('@');
                            if (_hasAtSymbol && _emailError != null) {
                              _emailError = null;
                            }
                          });
                        },
                      ),
                      
                      // Scritta esplicativa sotto la casella email
                      if (!_hasAtSymbol)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 5.0, left: 5.0),
                            child: Text(
                              'Inserire una @',
                              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 15),

                      // Campo ETÀ (Solo Tastiera Numerica)
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _buildInputDecoration('ETÀ'),
                      ),
                      
                      const SizedBox(height: 15),

                      // Campo PASSWORD (Bloccato a max 8 caratteri)
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: _buildInputDecoration('PASSWORD', errorText: _passwordError),
                      ),
                      
                      // Scritta esplicativa sotto la casella password
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.0, left: 5.0),
                          child: Text(
                            'Puoi inserire al massimo 8 caratteri',
                            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),

                      // Menù a tendina VALUTA
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.black,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          iconEnabledColor: Colors.white,
                          decoration: _buildInputDecoration('VALUTA'),
                          items: _currencies.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(letterSpacing: 1.2)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Pulsante CONFERMA
                      ElevatedButton(
                        onPressed: _isCaricamento ? null : () async {
                          FocusScope.of(context).unfocus();
                          if (_usernameController.text.isEmpty || 
                            _emailController.text.isEmpty || 
                            _ageController.text.isEmpty || 
                            _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Errore: Compila tutti i campi!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return; 
                            }

    if (_validaCampi()) {
      
      // 1. BLOCCO IL PULSANTE
      setState(() {
        _isCaricamento = true;
      });

      // 2. USO IL TRIM() QUI SUI CAMPI DI TESTO
      Utente utenteDaSalvare = Utente(
        id: Sessione.idUtenteAttuale, 
        username: _usernameController.text.trim(), 
        password: _passwordController.text,
        email: _emailController.text.trim(), 
        eta: int.tryParse(_ageController.text) ?? 18,
        valuta: _selectedCurrency,
        fotoProfilo: _immagineSelezionata?.path,
      );

      AuthController auth = AuthController();
      String? erroreDatabase;

      // 3. ESEGUO L'AZIONE NEL DB
      if (Sessione.idUtenteAttuale != null) {
        erroreDatabase = await auth.aggiornaUtente(utenteDaSalvare);
      } else {
        erroreDatabase = await auth.registraUtente(utenteDaSalvare);
      }

      // 4. SBLOCCO IL PULSANTE
      if (context.mounted) {
        setState(() {
          _isCaricamento = false;
        });
      }

      // 5. GESTISCO I MESSAGGI A SCHERMO
      if (erroreDatabase == null && context.mounted) {
        if (Sessione.idUtenteAttuale != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profilo aggiornato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrazione completata! Effettua il login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERRORE DB: $erroreDatabase'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(
    disabledBackgroundColor: Colors.grey[800], 
    backgroundColor: Colors.black,
    minimumSize: const Size(220, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: _isCaricamento 
    ? const SizedBox(
        height: 25, 
        width: 25, 
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
      )
    : const Text(
        'CONFERMA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}