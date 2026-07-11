import 'package:flutter/material.dart';
import 'BottomBar.dart';
import 'package:travel_app_02/route.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      
      // --- BARRA SUPERIORE ---
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true, // Centra il titolo come nel disegno
        title: const Text(
          'IL TUO PROFILO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      
      // --- CORPO CENTRALE ---
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // stretch allarga automaticamente i bottoni per riempire la larghezza
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            
            // 1. SEZIONE INFO UTENTE (Icona + Testi)
            Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 85,
                  color: Colors.black,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'USERNAME: UtenteTest', // Qui andrà la variabile del Model
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'EMAIL: test@email.com', // Qui andrà la variabile del Model
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),

            // 2. BOTTONE MODIFICA
            _buildMenuButton(
              testo: 'MODIFICA',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
                // TODO: Collegare il metodo del Controller per andare alla schermata di modifica
              },
            ),
            
            const SizedBox(height: 25),

            // 3. BOTTONE STATISTICHE
            _buildMenuButton(
              testo: 'STATISTICHE',
              onPressed: () {
                // TODO: Collegare il metodo del Controller per andare alle statistiche
                Navigator.pushNamed(context, AppRoutes.statsPage);
              },
            ),
            
            const SizedBox(height: 25),

            // 4. BOTTONE LOGOUT CON ICONA
            _buildMenuButton(
              testo: 'LOGOUT',
              icona: Icons.power_settings_new, // L'icona di accensione/spegnimento
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.start);
                // TODO: Collegare il metodo del Controller per effettuare il logout
              },
            ),

            const SizedBox(height: 25),

            // 5. BOTTONE ELIMINA ACCOUNT
            _buildMenuButton(
              testo: 'ELIMINA ACCOUNT',
              icona: Icons.delete_forever,
              onPressed: () async {
                // TODO: Chiamare _profileController.eliminaAccount(idUtente);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account eliminato', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.black,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Rimuove la cronologia di navigazione e torna alla pagina di Start
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.start, (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      
      // --- BARRA DI NAVIGAZIONE INFERIORE ---
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // --- FUNZIONE DI SUPPORTO PER I BOTTONI ---
  // Rende il codice molto più pulito evitando di riscrivere lo stesso blocco 3 volte
  Widget _buildMenuButton({required String testo, IconData? icona, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20), // Altezza del bottone
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Angoli squadrati
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centra il contenuto del bottone
        children: [
          if (icona != null) ...[
            Icon(icona, color: Colors.white, size: 28),
            const SizedBox(width: 10),
          ],
          Text(
            testo,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}