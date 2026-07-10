class Spesa {
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

  Spesa({
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
}