import 'package:cloud_firestore/cloud_firestore.dart';

class Servico {
  String? id;
  String empresa;
  String descricaoServico;
  DateTime dataServico;
  double valorCobrado;
  String tipoServico;
  String statusNf;

  Servico({
    this.id,
    required this.empresa,
    required this.descricaoServico,
    required this.dataServico,
    required this.valorCobrado,
    required this.tipoServico,
    this.statusNf = 'Pendente',
  });

  factory Servico.fromMap(Map<String, dynamic> map, String documentId) {
    return Servico(
      id: documentId,
      empresa: map['empresa'] ?? '',
      descricaoServico: map['descricaoServico'] ?? '',
      dataServico: (map['dataServico'] as Timestamp).toDate(),
      valorCobrado: (map['valorCobrado'] ?? 0.0).toDouble(),
      tipoServico: map['tipoServico'] ?? 'Regular',
      statusNf: map['statusNf'] ?? 'Pendente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'descricaoServico': descricaoServico,
      'dataServico': Timestamp.fromDate(dataServico),
      'valorCobrado': valorCobrado,
      'tipoServico': tipoServico,
      'statusNf': statusNf,
    };
  }
}