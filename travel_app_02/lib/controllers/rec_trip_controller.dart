import 'package:flutter/material.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/trip.dart';

class RecTripController extends ChangeNotifier {
  final Trip trip;

  RecTripController({required this.trip});
  
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

  void aggiungiSpesa(Expense spesa) {
    trip.spese.add(spesa);
    notifyListeners(); 
  }
}