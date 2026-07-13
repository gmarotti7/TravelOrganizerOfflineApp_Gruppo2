import 'package:flutter/material.dart';
import 'package:travel_app_02/models/expense.dart';
import 'package:travel_app_02/models/trip.dart';

class RecTripController extends ChangeNotifier {
  final Trip trip;

  RecTripController({required this.trip});
  
  double get speseTotali {
    return trip.spese.fold(0, (sum, item) => sum + item.importo);
  }

  // Sostituisci il getter statoViaggioColor con questo:
  Color get statoViaggioColor {
    final now = DateTime.now();
    final oggi = DateTime(now.year, now.month, now.day);
    final inizio = DateTime(trip.dataInizio.year, trip.dataInizio.month, trip.dataInizio.day);
    final fine = DateTime(trip.dataFine.year, trip.dataFine.month, trip.dataFine.day);

    if (oggi.isBefore(inizio)) {
      return Colors.green;
    } else if (oggi.isAfter(fine)) {
      return Colors.red;
    } else {
      return Colors.yellowAccent;
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

  void rimuoviSpesa(Expense spesa) {
    trip.spese.remove(spesa);
    notifyListeners();
  }

  void sostituisciSpesa(Expense vecchia, Expense nuova) {
    final indice = trip.spese.indexOf(vecchia);
    if (indice != -1) {
      trip.spese[indice] = nuova;
      notifyListeners();
    }
  }
}