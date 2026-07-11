import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart';
import 'package:travel_app_02/sessione.dart';
import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/controllers/profile_controller.dart';
import 'BottomBar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Istanziamo il controller
    final ProfileController _profileController = ProfileController();
    
    // 2. Recuperiamo l'ID della sessione (se sei loggato, sarà il tuo ID reale)
    final int idUtente = Sessione.idUtenteAttuale ?? 1;

    return Scaffold(
      backgroundColor: Colors.amber,
      
      // --- BARRA SUPERIORE ---
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'IL TUO PROFILO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      
      // --- CORPO CENTRALE DINAMICO ---
      // FutureBuilder interroga il database in background prima di mostrare la UI
      body: FutureBuilder<Utente?>(
        future: _profileController.getUtenteLoggato(idUtente),
        builder: (context, snapshot) {
          
          // Mentre carica, mostra un cerchio di caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          // Estrapoliamo i dati dal database
          final Utente? utente = snapshot.data;
          
          // Se non trova dati, usa valori di default
          final String usernameDisplay = utente?.username ?? 'Ospite';
          final String emailDisplay = utente?.email ?? 'Nessuna email';
          final String fotoPath = utente?.fotoProfilo ?? '';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                
                // 1. SEZIONE INFO UTENTE (Immagine + Testi)
                Row(
                  children: [
                    // FOTO PROFILO DINAMICA
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.black, // Sfondo di base
                        shape: BoxShape.circle,
                        // Se c'è un percorso foto, la carica dal file system
                        image: fotoPath.isNotEmpty 
                          ? DecorationImage(
                              image: FileImage(File(fotoPath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      // Mostra l'icona bianca base SOLO se la foto non c'è
                      child: fotoPath.isEmpty 
                        ? const Icon(Icons.person, size: 60, color: Colors.white54)
                        : null,
                    ),
                    const SizedBox(width: 15),
                    
                    // TESTI DINAMICI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USERNAME: $usernameDisplay',
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'EMAIL: $emailDisplay', 
                            style: const TextStyle(
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
                    // TODO: Aggiungere logica di modifica
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                ),
                
                const SizedBox(height: 25),

                // 3. BOTTONE STATISTICHE
                _buildMenuButton(
                  testo: 'STATISTICHE',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.statsPage);
                  },
                ),
                
                const SizedBox(height: 25),

                // 4. BOTTONE LOGOUT
                _buildMenuButton(
                  testo: 'LOGOUT',
                  icona: Icons.power_settings_new, 
                  onPressed: () {
                    // Pulisce la sessione disconnettendo l'utente
                    Sessione.idUtenteAttuale = null;
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.start, (route) => false);
                  },
                ),

                const SizedBox(height: 25),

                // 5. BOTTONE ELIMINA ACCOUNT
                _buildMenuButton(
                  testo: 'ELIMINA ACCOUNT',
                  icona: Icons.delete_forever,
                  coloreSfondo: Colors.red, // Rosso per pericolo
                  onPressed: () async {
                    bool eliminato = await _profileController.eliminaAccount(idUtente);
                    
                    if (eliminato && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account eliminato con successo.', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.black,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      
                      Sessione.idUtenteAttuale = null;
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.start, (route) => false);
                    }
                  },
                ),
              ],
            ),
          );
        }
      ),
      
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // --- WIDGET DI SUPPORTO PER I BOTTONI ---
  Widget _buildMenuButton({
    required String testo, 
    IconData? icona, 
    Color coloreSfondo = Colors.black,
    required VoidCallback onPressed
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: coloreSfondo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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