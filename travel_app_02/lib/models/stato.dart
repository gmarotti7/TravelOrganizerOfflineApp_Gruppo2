class stato {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;

  stato({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  factory stato.fromMap(Map<String, dynamic> map){
    return stato(
      id: map['id'] as String,
      title: map['title'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

}