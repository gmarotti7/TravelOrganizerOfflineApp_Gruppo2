// lib/views/login.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app_02/route.dart'; // Import per accedere ad AppRoutes

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controller per catturare i testi di input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Stringa per gestire il messaggio d'errore sopra il pulsante Accedi
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Funzione di utilità per lo stile uniforme dei campi di testo neri
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Simulazione della verifica offline
  bool _verificaCredenzialiDatabase(String username, String password) {
    if (username == 'admin' && password == '1234') {
      return true;
    }
    return false;
  }

  void _eseguiLogin() {
    String usernameInput = _usernameController.text.trim();
    String passwordInput = _passwordController.text;

    if (usernameInput.isEmpty || passwordInput.isEmpty) {
      setState(() {
        _errorMessage = "Compila tutti i campi richiesti";
      });
      return;
    }

    bool isValido = _verificaCredenzialiDatabase(usernameInput, passwordInput);

    if (isValido) {
      setState(() {
        _errorMessage = null;
      });
      debugPrint("Login effettuato con successo! Navigazione...");
      
      // CORRETTO: Cambiato in AppRoutes.start come definito nel tuo main.dart
      Navigator.pushReplacementNamed(context, AppRoutes.start);
    } else {
      setState(() {
        _errorMessage = "username o password non corretto, riprova";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 170, 5, 1), // Giallo ocra
      body: SafeArea(
        child: Stack(
          children: [
            // Freccia in alto a sinistra per tornare indietro alla pagina start
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context); // Torna indietro alla schermata precedente (start)
                },
              ),
            ),
            
            // Contenuto centrale della pagina
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), // Spazio per non sovrapporsi alla freccia
                      
                      // Titolo in alto al centro
                      const Text(
                        'INSERISCI I TUOI DATI DI ACCESSO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 50),

                      // Campo USERNAME
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: _buildInputDecoration('USERNAME'),
                      ),
                      
                      const SizedBox(height: 20),

                      // Campo PASSWORD (Max 8 caratteri)
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: _buildInputDecoration('PASSWORD'),
                      ),
                      
                      const SizedBox(height: 40),

                      // Scritta d'errore dinamica in rosso SOPRA il pulsante ACCEDI
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // Pulsante ACCEDI
                      ElevatedButton(
                        onPressed: _eseguiLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ACCEDI',
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