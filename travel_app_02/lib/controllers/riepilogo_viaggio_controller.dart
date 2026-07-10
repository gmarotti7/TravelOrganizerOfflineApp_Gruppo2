import 'package:flutter/material.dart';
import 'package:travel_app_02/models/spesa.dart';
import 'package:travel_app_02/models/viaggio.dart';

// 🔴 Aggiungere "extends ChangeNotifier"
class RiepilogoViaggioController extends ChangeNotifier {
  final Viaggio trip;

  RiepilogoViaggioController({required this.trip});
  
  double get speseTotali {
    return trip.spese.fold(0, (sum, item) => sum + item.importo);
  }

  Color get statoViaggioColor {
    final now = DateTime.now();
    if (now.isBefore(trip.dataInizio)) {
      return Colors.red; 
    } else if (now.isAfter(trip.dataFine)) {
      return Colors.green; 
    } else {
      return Colors.amber; 
    }
  }

  Color get speseTotaliColor {
    if (speseTotali > trip.budgetPrevisto) {
      return Colors.red; 
    } else {
      return Colors.green; 
    }
  }

  void aggiungiSpesa(Spesa spesa) {
    trip.spese.add(spesa);
    notifyListeners(); 
  }
}