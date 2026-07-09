// lib/views/sign_up.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  
  // Variabile per la valuta selezionata
  String _selectedCurrency = 'EUR';

  // Lista delle valute principali
  final List<String> _currencies = ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];

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
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1), // Giallo ocra
      body: SafeArea(
        child: Stack(
          children: [
            // Freccia bianca in alto a sinistra per tornare indietro
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context); // Torna indietro alla schermata start
                },
              ),
            ),

            // Contenuto centrale del modulo
            Center(
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
                        onPressed: () {
                          if (_validaCampi()) {
                            print("Dati validi! Pronto al salvataggio.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
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
          ],
        ),
      ),
    );
  }
}