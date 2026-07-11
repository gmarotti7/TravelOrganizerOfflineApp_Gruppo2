class Stay {
  final String id;
  final String titolo;
  final String data;
  final String ora;
  final String? descrizione;
  final double costoPrevisto;

  Stay({
    required this.id,
    required this.titolo,
    required this.data,
    required this.ora,
    this.descrizione,
    required this.costoPrevisto,
  });

  // Da Oggetto a riga SQLite
  Map<String, dynamic> toMap(int idViaggio) {
    return {
      'titolo': titolo,
      'data': data,
      'ora': ora,
      'descrizione': descrizione ?? '',
      'costoPrevisto': costoPrevisto,
      'idViaggio': idViaggio,
    };
  }

  // Da riga SQLite a Oggetto
  factory Stay.fromMap(Map<String, dynamic> map) {
    return Stay(
      id: map['id'].toString(),
      titolo: map['titolo'],
      data: map['data'] ?? '',
      ora: map['ora'] ?? '',
      descrizione: map['descrizione'],
      costoPrevisto: (map['costoPrevisto'] as num?)?.toDouble() ?? 0.0,
    );
  }
}