import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/services/database_helper.dart';

class CostController {

  // Salva una spesa nel database SQLite
  Future<Expense> salvaSpesa(Expense spesa, int idViaggio) async {
    final id = await DatabaseHelper.instance.insert(
      'spese',
      spesa.toMap(idViaggio),
    );
    return Expense(
      id: id.toString(),
      titolo: spesa.titolo,
      importo: spesa.importo,
      data: spesa.data,
      stato: spesa.stato,
      descrizione: spesa.descrizione,
      metodoPagamento: spesa.metodoPagamento,
      categoria: spesa.categoria,
      attivitaAssociata: spesa.attivitaAssociata,
      viaggioAssociato: idViaggio.toString(),
      valuta: spesa.valuta,
    );
  }

  // Carica tutte le spese associate a un viaggio
  Future<List<Expense>> caricaSpeseViaggio(int idViaggio) async {
    final mappe = await DatabaseHelper.instance.queryAllRows(
      'spese',
      where: 'idViaggio = ?',
      whereArgs: [idViaggio],
    );
    return mappe.map((m) => Expense.fromMap(m)).toList();
  }

  // Carica una singola spesa dal DB tramite id (usato per ricaricare i dati aggiornati dopo una modifica)
  Future<Expense?> caricaSpesa(String idSpesa) async {
    final mappe = await DatabaseHelper.instance.queryAllRows(
      'spese',
      where: 'id = ?',
      whereArgs: [idSpesa],
    );
    if (mappe.isEmpty) return null;
    return Expense.fromMap(mappe.first);
  }

  // Elimina una spesa dal DB
  Future<void> eliminaSpesa(String idSpesa) async {
    await DatabaseHelper.instance.delete(
      'spese',
      where: 'id = ?',
      whereArgs: [idSpesa],
    );
  }

  // Aggiorna un singolo campo di una spesa
  Future<void> aggiornaCampoSpesa(String idSpesa, String colonna, dynamic valore) async {
    await DatabaseHelper.instance.update(
      'spese',
      {colonna: valore},
      where: 'id = ?',
      whereArgs: [idSpesa],
    );
  }
}