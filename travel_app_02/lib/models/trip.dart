import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/stay.dart';

class Trip {
  String id;
  String titolo;
  String luogo;
  DateTime dataInizio;
  DateTime dataFine;
  double budgetPrevisto;
  List<Stay> tappe;
  List<Expense> spese;

  Trip({
    required this.id,
    required this.titolo,
    required this.luogo,
    required this.dataInizio,
    required this.dataFine,
    required this.budgetPrevisto,
    List<Stay>? tappe,
    List<Expense>? spese,
  })  : tappe = tappe ?? [],
        spese = spese ?? [];

  // Da Oggetto a riga SQLite
  Map<String, dynamic> toMap(int idUtente) {
    return {
      'titolo': titolo,
      'luogo': luogo,
      'dataInizio': dataInizio.toIso8601String(),
      'dataFine': dataFine.toIso8601String(),
      'budgetPrevisto': budgetPrevisto,
      'idUtente': idUtente,
    };
  }

  // Da riga SQLite a Oggetto
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'].toString(),
      titolo: map['titolo'],
      luogo: map['luogo'],
      dataInizio: DateTime.parse(map['dataInizio']),
      dataFine: DateTime.parse(map['dataFine']),
      budgetPrevisto: map['budgetPrevisto'],
    );
  }
}