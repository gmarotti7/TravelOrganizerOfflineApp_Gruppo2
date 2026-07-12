import 'package:travel_app_02/models/stay.dart';
import 'package:travel_app_02/services/database_helper.dart';

class StayController {
  // Salva una nuova tappa nel DB, collegata al viaggio
  Future<Stay> salvaNuovaTappa(Stay tappa, int idViaggio) async {
    final id = await DatabaseHelper.instance.insert(
      'tappe',
      tappa.toMap(idViaggio),
    );
    return Stay(
      id: id.toString(),
      titolo: tappa.titolo,
      data: tappa.data,
      ora: tappa.ora,
      descrizione: tappa.descrizione,
      costoPrevisto: tappa.costoPrevisto,
    );
  }

  // Carica tutte le tappe di un viaggio
  Future<List<Stay>> caricaTappeViaggio(int idViaggio) async {
    final mappe = await DatabaseHelper.instance.queryAllRows(
      'tappe',
      where: 'idViaggio = ?',
      whereArgs: [idViaggio],
    );
    return mappe.map((mappa) => Stay.fromMap(mappa)).toList();
  }

  // Elimina una tappa dal DB
  Future<void> eliminaTappa(String idTappa) async {
    await DatabaseHelper.instance.delete(
      'tappe',
      where: 'id = ?',
      whereArgs: [idTappa],
    );
  }

  // Aggiorna un singolo campo di una tappa (usato dalla schermata di modifica)
  // 'colonna' deve essere il nome della colonna nel DB
  // (es. 'titolo', 'data', 'ora', 'descrizione', 'costoPrevisto')
  Future<void> aggiornaCampoTappa(String idTappa, String colonna, dynamic valore) async {
    await DatabaseHelper.instance.update(
      'tappe',
      {colonna: valore},
      where: 'id = ?',
      whereArgs: [idTappa],
    );
  }
}