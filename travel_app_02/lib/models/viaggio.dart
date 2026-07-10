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
}