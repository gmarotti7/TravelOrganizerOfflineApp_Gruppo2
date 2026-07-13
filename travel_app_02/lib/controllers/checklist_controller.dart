import 'package:travel_app_02/services/database_helper.dart';

class ChecklistController {
  // MODIFICA: Ora restituisce TUTTE le checklist associate al viaggio sotto forma di lista
  Future<List<Map<String, dynamic>>> caricaChecklistViaggio(int idViaggio) async {
    final righe = await DatabaseHelper.instance.queryAllRows(
      'checklist',
      where: 'idViaggio = ?',
      whereArgs: [idViaggio],
    );
    return righe; // Restituisce l'intera lista di righe trovate senza fermarsi alla prima
  }

  Future<List<Map<String, dynamic>>> caricaElementi(int idChecklist) async {
    return DatabaseHelper.instance.queryAllRows(
      'checklist_items',
      where: 'idChecklist = ?',
      whereArgs: [idChecklist],
    );
  }

  // Salva una nuova checklist con i suoi elementi. 'elementi' arriva da AddCheck:
  // [{'nome': ..., 'isChecked': ...}, ...]
  Future<int> salvaChecklist(String titolo, List<Map<String, dynamic>> elementi, int idViaggio) async {
    final idChecklist = await DatabaseHelper.instance.insert('checklist', {
      'titolo': titolo,
      'idViaggio': idViaggio,
    });

    for (final elemento in elementi) {
      await DatabaseHelper.instance.insert('checklist_items', {
        'nomeItem': elemento['nome'],
        'isCompletato': (elemento['isChecked'] == true) ? 1 : 0,
        'idChecklist': idChecklist,
      });
    }

    return idChecklist;
  }

  Future<void> aggiornaStatoElemento(int idItem, bool completato) async {
    await DatabaseHelper.instance.update(
      'checklist_items',
      {'isCompletato': completato ? 1 : 0},
      where: 'id = ?',
      whereArgs: [idItem],
    );
  }

  Future<void> eliminaChecklist(int idChecklist) async {
    await DatabaseHelper.instance.delete(
      'checklist',
      where: 'id = ?',
      whereArgs: [idChecklist],
    );
  }

  Future<void> aggiornaTitolo(int idChecklist, String nuovoTitolo) async {
    await DatabaseHelper.instance.update(
      'checklist',
      {'titolo': nuovoTitolo},
      where: 'id = ?',
      whereArgs: [idChecklist],
    );
  }

  // Aggiunge un nuovo elemento a una checklist già esistente
  Future<int> aggiungiElemento(int idChecklist, String nomeItem) async {
    return DatabaseHelper.instance.insert('checklist_items', {
      'nomeItem': nomeItem,
      'isCompletato': 0,
      'idChecklist': idChecklist,
    });
  }

  // Modifica il nome di un singolo elemento della checklist
  Future<void> aggiornaNomeElemento(int idItem, String nuovoNome) async {
    await DatabaseHelper.instance.update(
      'checklist_items',
      {'nomeItem': nuovoNome},
      where: 'id = ?',
      whereArgs: [idItem],
    );
  }

  // Elimina un singolo elemento dalla checklist
  Future<void> eliminaElemento(int idItem) async {
    await DatabaseHelper.instance.delete(
      'checklist_items',
      where: 'id = ?',
      whereArgs: [idItem],
    );
  }
}