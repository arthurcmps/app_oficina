class Empresa {
  final String id;
  final String nome;

  Empresa({
    required this.id,
    required this.nome,
  });

  // Converte de Firestore (Map) para Objeto Dart
  factory Empresa.fromMap(Map<String, dynamic> map, String documentId) {
    return Empresa(
      id: documentId,
      nome: map['nome'] ?? '',
    );
  }

  // Converte de Objeto Dart para Firestore (Map)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }
}