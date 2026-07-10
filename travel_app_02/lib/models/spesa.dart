class Spesa {
  final String id;
  final String titolo;
  final double importo;
  final String? stato;
  final String? data;
  final String? descrizione;
  final String? metodoPagamento;

  Spesa({
    required this.id, 
    required this.titolo, 
    required this.importo,
    this.stato,
    this.data,
    this.descrizione,
    this.metodoPagamento,
  });
}