import 'package:travel_app_02/services/database_helper.dart';

class PackController {
  // Restituisce la packlist del viaggio (se esiste). Un viaggio ne ha al massimo una.
  Future<Map<String, dynamic>?> caricaPacklistViaggio(int idViaggio) async {
    final righe = await DatabaseHelper.instance.queryAllRows(
      'packlist',
      where: 'idViaggio = ?',
      whereArgs: [idViaggio],
    );
    return righe.isEmpty ? null : righe.first;
  }

  Future<List<Map<String, dynamic>>> caricaElementi(int idPacklist) async {
    return DatabaseHelper.instance.queryAllRows(
      'packlist_items',
      where: 'idPacklist = ?',
      whereArgs: [idPacklist],
    );
  }

  // Salva una nuova packlist con i suoi elementi. 'elementi' arriva da AddPack:
  // [{'nome': ..., 'isChecked': ...}, ...]
  Future<int> salvaPacklist(String titolo, List<Map<String, dynamic>> elementi, int idViaggio) async {
    final idPacklist = await DatabaseHelper.instance.insert('packlist', {
      'titolo': titolo,
      'idViaggio': idViaggio,
    });

    for (final elemento in elementi) {
      await DatabaseHelper.instance.insert('packlist_items', {
        'nomeItem': elemento['nome'],
        'isImballato': (elemento['isChecked'] == true) ? 1 : 0,
        'idPacklist': idPacklist,
      });
    }

    return idPacklist;
  }

  Future<void> aggiornaStatoElemento(int idItem, bool imballato) async {
    await DatabaseHelper.instance.update(
      'packlist_items',
      {'isImballato': imballato ? 1 : 0},
      where: 'id = ?',
      whereArgs: [idItem],
    );
  }

  Future<void> eliminaPacklist(int idPacklist) async {
    await DatabaseHelper.instance.delete(
      'packlist',
      where: 'id = ?',
      whereArgs: [idPacklist],
    );
  }

  Future<void> aggiornaTitolo(int idPacklist, String nuovoTitolo) async {
    await DatabaseHelper.instance.update(
      'packlist',
      {'titolo': nuovoTitolo},
      where: 'id = ?',
      whereArgs: [idPacklist],
    );
  }
}