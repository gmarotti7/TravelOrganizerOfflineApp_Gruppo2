class Utente {
  int? id;
  String username;
  String password;
  String email;
  int eta;
  String valuta;
  String? fotoProfilo;

  Utente({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.eta,
    required this.valuta,
    this.fotoProfilo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email, 
      'eta': eta,
      'valuta': valuta,
      'fotoProfilo': fotoProfilo,
    };
  }

  factory Utente.fromMap(Map<String, dynamic> map) {
    return Utente(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'], 
      eta: map['eta'],
      valuta: map['valuta'],
      fotoProfilo: map['fotoProfilo'],
    );
  }
}