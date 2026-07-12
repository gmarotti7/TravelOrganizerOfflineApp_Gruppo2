import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/services/database_helper.dart';

class ProfileController {
  
  // Recupera i dati dell'utente dal database tramite il suo ID
  Future<Utente?> getUtenteLoggato(int idUtente) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'utenti',
      where: 'id = ?',
      whereArgs: [idUtente],
    );

    if (result.isNotEmpty) {
      return Utente.fromMap(result.first);
    }
    return null;
  }

  // Elimina l'utente (a cascata verranno eliminati anche viaggi e spese)
  Future<bool> eliminaAccount(int idUtente) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('utenti', where: 'id = ?', whereArgs: [idUtente]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Aggiorna un singolo campo del profilo (usato dalla schermata di modifica,
  // dove l'utente sceglie quale campo cambiare: username, email, età, valuta...)
  Future<void> aggiornaCampoUtente(int idUtente, String colonna, dynamic valore) async {
    await DatabaseHelper.instance.update(
      'utenti',
      {colonna: valore},
      where: 'id = ?',
      whereArgs: [idUtente],
    );
  }
}