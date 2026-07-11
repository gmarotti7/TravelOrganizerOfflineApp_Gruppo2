import 'package:travel_app_02/services/database_helper.dart';

class ChecklistController {
  // Restituisce la checklist del viaggio (se esiste). Un viaggio ne ha al massimo una.
  Future<Map<String, dynamic>?> caricaChecklistViaggio(int idViaggio) async {
    final righe = await DatabaseHelper.instance.queryAllRows(
      'checklist',
      where: 'idViaggio = ?',
      whereArgs: [idViaggio],
    );
    return righe.isEmpty ? null : righe.first;
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
}