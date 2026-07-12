import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart';
import 'package:travel_app_02/sessione.dart';
import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/controllers/profile_controller.dart';
import 'BottomBar.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _profileController = ProfileController();
  late Future<Utente?> _futureUtente;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _caricaUtente();
  }

  void _caricaUtente() {
    final int idUtente = Sessione.idUtenteAttuale ?? 1;
    _futureUtente = _profileController.getUtenteLoggato(idUtente);
  }

  // Menu a tendina: quale campo del profilo vuoi modificare
  void _mostraMenuModificaProfilo(BuildContext context, Utente utente) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Foto Profilo'),
              onTap: () {
                Navigator.pop(context);
                _mostraMenuSceltaFoto(utente);
              },
            ),
            ListTile(
              title: const Text('Username'),
              onTap: () => _apriModificaCampo(context, utente, 'username', 'Username'),
            ),
            ListTile(
              title: const Text('Email'),
              onTap: () => _apriModificaCampo(context, utente, 'email', 'Email'),
            ),
            ListTile(
              title: const Text('Età'),
              onTap: () => _apriModificaCampo(context, utente, 'eta', 'Età'),
            ),
            ListTile(
              title: const Text('Valuta'),
              onTap: () => _apriModificaCampo(context, utente, 'valuta', 'Valuta'),
            ),
            ListTile(
              title: const Text('Password'),
              onTap: () => _apriModificaCampo(context, utente, 'password', 'Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apriModificaCampo(BuildContext context, Utente utente, String campo, String label) async {
    Navigator.pop(context); // chiude il menu a tendina

    final risultato = await Navigator.pushNamed(
      context,
      AppRoutes.editProfileField,
      arguments: {'utente': utente, 'campo': campo, 'label': label},
    );

    if (risultato != null && risultato is Map) {
      // Ricarichiamo i dati dal database così la pagina mostra subito il
      // valore aggiornato (utile anche per la password, che non torna qui).
      setState(() {
        _caricaUtente();
      });
    }
  }
  
  void _mostraMenuSceltaFoto(Utente utente) {
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
                _scegliImmagine(ImageSource.gallery, utente);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: const Text('Scatta una Foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _scegliImmagine(ImageSource.camera, utente);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scegliImmagine(ImageSource sorgente, Utente utente) async {
    final XFile? immagine = await _picker.pickImage(source: sorgente);
    
    if (immagine != null) {
      try {
        // Salva il nuovo percorso dell'immagine nel database
        await _profileController.aggiornaCampoUtente(utente.id!, 'fotoProfilo', immagine.path);
        
        if (mounted) {
          // Ricarica l'utente e aggiorna la pagina in tempo reale
          setState(() {
            _caricaUtente();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profilo aggiornata!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante il salvataggio: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Forziamo il ritorno alla Home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.amber,

        // --- BARRA SUPERIORE ---
        appBar: AppBar(
          backgroundColor: Colors.amber,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        body: FutureBuilder<Utente?>(
          future: _futureUtente,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            final int idUtente = Sessione.idUtenteAttuale ?? 1;
            final Utente? utente = snapshot.data;

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
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          image: fotoPath.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(fotoPath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: fotoPath.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'USERNAME: $usernameDisplay',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'EMAIL: $emailDisplay',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                    onPressed: utente == null
                        ? null
                        : () => _mostraMenuModificaProfilo(context, utente),
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
                      Sessione.idUtenteAttuale = null;
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.start, (route) => false);
                    },
                  ),

                  const SizedBox(height: 25),

                  // 5. BOTTONE ELIMINA ACCOUNT
                  _buildMenuButton(
                    testo: 'ELIMINA ACCOUNT',
                    icona: Icons.delete_forever,
                    coloreSfondo: Colors.red,
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
          },
        ),

        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  // --- WIDGET DI SUPPORTO PER I BOTTONI ---
  Widget _buildMenuButton({
    required String testo,
    IconData? icona,
    Color coloreSfondo = Colors.black,
    required VoidCallback? onPressed,
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}