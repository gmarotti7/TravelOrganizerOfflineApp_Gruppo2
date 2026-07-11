import 'package:travel_app_02/models/spesa.dart';
import 'package:travel_app_02/models/tappa.dart';

class Viaggio {
  String id;
  String titolo;
  String luogo;
  DateTime dataInizio;
  DateTime dataFine;
  double budgetPrevisto;
  List<Tappa> tappe;
  List<Spesa> spese;

  Viaggio({
    required this.id,
    required this.titolo,
    required this.luogo,
    required this.dataInizio,
    required this.dataFine,
    required this.budgetPrevisto,
    this.tappe = const [],
    this.spese = const [],
  });

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
  factory Viaggio.fromMap(Map<String, dynamic> map) {
    return Viaggio(
      id: map['id'].toString(),
      titolo: map['titolo'],
      luogo: map['luogo'],
      dataInizio: DateTime.parse(map['dataInizio']),
      dataFine: DateTime.parse(map['dataFine']),
      budgetPrevisto: map['budgetPrevisto'],
    );
  }
}