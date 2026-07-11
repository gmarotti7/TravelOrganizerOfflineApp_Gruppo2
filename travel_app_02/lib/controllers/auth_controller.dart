import 'package:travel_app_02/models/utente.dart';
import 'package:travel_app_02/services/database_helper.dart';

class AuthController {
  
  // Metodo per registrare un nuovo utente nel database
  Future<String?> registraUtente(Utente nuovoUtente) async {
    try {
      await DatabaseHelper.instance.insert('utenti', nuovoUtente.toMap());
      return null;
    } catch (e) {
      
      return e.toString(); 
    }
  }

  // Metodo per fare il Login
  Future<Utente?> eseguiLogin(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> mappeUtenti = await db.query(
      'utenti',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (mappeUtenti.isNotEmpty) {
      return Utente.fromMap(mappeUtenti.first);
    }
    return null;
  }
}