import 'package:intl/intl.dart';
import 'package:travel_app_02/models/viaggio.dart';
import 'package:travel_app_02/services/database_helper.dart';

class ViaggioController {
  
  // Metodo di validazione incapsulato nel Controller
  bool validaNuovoViaggio(String nuovoTitolo, String dataInizioStr, String dataFineStr, List<Viaggio> viaggiEsistenti) {
    final format = DateFormat('dd/MM/yyyy');
    DateTime nuovaDataInizio = format.parse(dataInizioStr);
    DateTime nuovaDataFine = format.parse(dataFineStr);

    // CONTROLLO 1: Nome duplicato
    bool nomeDuplicato = viaggiEsistenti.any((v) => v.titolo.toLowerCase() == nuovoTitolo.toLowerCase());
    
    if (nomeDuplicato) {
      return false;
    }

    // CONTROLLO 2: Date sovrapposte
    bool dateSovrapposte = viaggiEsistenti.any((v) {
      // Usiamo direttamente le variabili del modello perché sono già DateTime
      DateTime inizioEsistente = v.dataInizio;
      DateTime fineEsistente = v.dataFine;

      return nuovaDataInizio.isBefore(fineEsistente.add(const Duration(days: 1))) && 
             nuovaDataFine.isAfter(inizioEsistente.subtract(const Duration(days: 1)));
    });
    
    if (dateSovrapposte) {
      return false;
    }

    // Se supera tutti i controlli, il viaggio è valido!
    return true; 
  }


  bool validaOperazioneSpesa(DateTime dataSpesa, Viaggio viaggio) {
    DateTime oggi = DateTime.now();
    DateTime soloDataOggi = DateTime(oggi.year, oggi.month, oggi.day);

    // Se oggi è prima dell'inizio del viaggio, non permettiamo l'operazione
    if (soloDataOggi.isBefore(viaggio.dataInizio)) {
      return false;
    }

    // REGOLA 3: La data della spesa deve essere compresa tra inizio e fine viaggio
    // Verifichiamo che la spesa sia >= inizio e <= fine
    bool isValida = dataSpesa.isAfter(viaggio.dataInizio.subtract(const Duration(days: 1))) && 
                  dataSpesa.isBefore(viaggio.dataFine.add(const Duration(days: 1)));

    return isValida;
  }


  // Salva il viaggio nel DB
  Future<Viaggio> salvaNuovoViaggio(Viaggio viaggio, int idUtente) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('viaggi', viaggio.toMap(idUtente));
    viaggio.id = id.toString();
    return viaggio;
  }

  // Carica i viaggi dell'utente dal DB
  Future<List<Viaggio>> caricaViaggiUtente(int idUtente) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> mappe = await db.query(
      'viaggi',
      where: 'idUtente = ?',
      whereArgs: [idUtente],
    );
    return mappe.map((mappa) => Viaggio.fromMap(mappa)).toList();
  }
  
}