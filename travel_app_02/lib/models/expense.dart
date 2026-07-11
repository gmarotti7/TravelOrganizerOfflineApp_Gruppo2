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
      'idViaggio': idViaggio,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'].toString(),
      titolo: map['titolo'],
      importo: map['importo'],
      data: map['data'],
    );
  }
}