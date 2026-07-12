class Expense {
  final String id;
  final String titolo;
  final double importo;
  final String? stato;
  final String? data;
  final String? descrizione;
  final String? metodoPagamento;
  // --- I 3 NUOVI CAMPI ---
  final String? categoria;
  final String? viaggioAssociato;
  final String? attivitaAssociata;

  Expense({
    required this.id, 
    required this.titolo, 
    required this.importo,
    this.stato,
    this.data,
    this.descrizione,
    this.metodoPagamento,
    // --- I 3 NUOVI CAMPI ---
    this.categoria,
    this.viaggioAssociato,
    this.attivitaAssociata,
  });

  Map<String, dynamic> toMap(int idViaggio) {
    return {
      'titolo': titolo,
      'importo': importo,
      'data': data ?? '',
      'stato': stato ?? '',
      'descrizione': descrizione ?? '',
      'metodoPagamento': metodoPagamento ?? '',
      'categoria': categoria ?? '',
      'attivitaAssociata': attivitaAssociata ?? '',
      'idViaggio': idViaggio,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'].toString(),
      titolo: map['titolo'],
      importo: (map['importo'] as num).toDouble(),
      data: map['data'],
      stato: map['stato'],
      descrizione: map['descrizione'],
      metodoPagamento: map['metodoPagamento'],
      categoria: map['categoria'],
      attivitaAssociata: map['attivitaAssociata'],
      viaggioAssociato: map['idViaggio']?.toString(),
    );
  }
}