import 'package:travel_app_02/controllers/trip_controller.dart';
import 'package:travel_app_02/controllers/cost_controller.dart';
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/models/expense.dart';

// Contiene i dati aggregati mostrati nella pagina Statistiche, calcolati a
// partire dai viaggi e dalle spese reali dell'utente (niente più dati finti).
class StatisticheUtente {
  final bool haViaggi;
  final bool haSpese;

  // Rispetto del budget: rapporto spesoTotale/budgetTotale sui viaggi che
  // hanno un budget previsto > 0.
  final double? percentualeBudget; // 0.0 -> 1.0+ (può superare 1 se si sfora)
  final double budgetTotale;
  final double speseSuBudget;

  final double costoMedioGiornaliero;

  // Luogo -> numero di viaggi in quel luogo, ordinato dal più frequente.
  final List<MapEntry<String, int>> destinazioniPreferite;
  final int numeroViaggiTotali;

  // Categoria -> totale speso in quella categoria.
  final List<MapEntry<String, double>> spesePerCategoria;

  StatisticheUtente({
    required this.haViaggi,
    required this.haSpese,
    required this.percentualeBudget,
    required this.budgetTotale,
    required this.speseSuBudget,
    required this.costoMedioGiornaliero,
    required this.destinazioniPreferite,
    required this.numeroViaggiTotali,
    required this.spesePerCategoria,
  });
}

class StatsController {
  final TripController _tripController = TripController();
  final CostController _costController = CostController();

  Future<StatisticheUtente> calcolaStatistiche(int idUtente) async {
    final List<Trip> viaggi = await _tripController.caricaViaggiUtente(idUtente);

    if (viaggi.isEmpty) {
      return StatisticheUtente(
        haViaggi: false,
        haSpese: false,
        percentualeBudget: null,
        budgetTotale: 0.0,
        speseSuBudget: 0.0,
        costoMedioGiornaliero: 0.0,
        destinazioniPreferite: const [],
        numeroViaggiTotali: 0,
        spesePerCategoria: const [],
      );
    }

    // Carichiamo le spese di tutti i viaggi in parallelo.
    final List<List<Expense>> speseXViaggio = await Future.wait(
      viaggi.map((v) => _costController.caricaSpeseViaggio(int.parse(v.id))),
    );

    final List<Expense> tutteLeSpese = speseXViaggio.expand((s) => s).toList();

    // --- 1. Rispetto del budget (solo viaggi con budget previsto > 0) ---
    double budgetTotale = 0;
    double speseSuBudget = 0;
    for (int i = 0; i < viaggi.length; i++) {
      final v = viaggi[i];
      if (v.budgetPrevisto > 0) {
        budgetTotale += v.budgetPrevisto;
        speseSuBudget += speseXViaggio[i].fold(0.0, (tot, s) => tot + s.importo);
      }
    }
    final double? percentualeBudget = budgetTotale > 0 ? (speseSuBudget / budgetTotale) : null;

    // --- 2. Costo medio giornaliero (spesa totale / giorni totali di viaggio) ---
    int giorniTotali = 0;
    for (final v in viaggi) {
      final int durata = v.dataFine.difference(v.dataInizio).inDays + 1;
      if (durata > 0) giorniTotali += durata;
    }
    final double speseTotali = tutteLeSpese.fold(0.0, (tot, s) => tot + s.importo);
    final double costoMedioGiornaliero = giorniTotali > 0 ? (speseTotali / giorniTotali) : 0.0;

    // --- 3. Destinazioni preferite (frequenza per luogo) ---
    final Map<String, int> conteggioLuoghi = {};
    for (final v in viaggi) {
      final luogo = v.luogo.trim().isEmpty ? 'Sconosciuto' : v.luogo.trim();
      conteggioLuoghi[luogo] = (conteggioLuoghi[luogo] ?? 0) + 1;
    }
    final destinazioniPreferite = conteggioLuoghi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // --- 4. Spese per categoria ---
    final Map<String, double> totaliCategoria = {};
    for (final s in tutteLeSpese) {
      final categoria = (s.categoria == null || s.categoria!.trim().isEmpty) ? 'Altro' : s.categoria!.trim();
      totaliCategoria[categoria] = (totaliCategoria[categoria] ?? 0) + s.importo;
    }
    final spesePerCategoria = totaliCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return StatisticheUtente(
      haViaggi: true,
      haSpese: tutteLeSpese.isNotEmpty,
      percentualeBudget: percentualeBudget,
      budgetTotale: budgetTotale,
      speseSuBudget: speseSuBudget,
      costoMedioGiornaliero: costoMedioGiornaliero,
      destinazioniPreferite: destinazioniPreferite,
      numeroViaggiTotali: viaggi.length,
      spesePerCategoria: spesePerCategoria,
    );
  }
}