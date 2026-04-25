import 'package:cloud_firestore/cloud_firestore.dart';

class Servico {
  final String id;
  final String numeroOs;
  final DateTime dataServico;
  final String empresa;
  final String nomeServico;
  final String descricaoServico;
  final String tipoServico;
  final double valorCobrado;
  final String statusNf;

  Servico({
    required this.id,
    required this.numeroOs,
    required this.dataServico,
    required this.empresa,
    required this.nomeServico,
    required this.descricaoServico,
    required this.tipoServico,
    required this.valorCobrado,
    this.statusNf = 'Pendente',
  });

  factory Servico.fromMap(Map<String, dynamic> map, String documentId) {
    return Servico(
      id: documentId,
      numeroOs: map['numeroOs'] ?? '',
      // Tratamento específico para o Timestamp do Firestore
      dataServico: (map['dataServico'] as Timestamp).toDate(),
      empresa: map['empresa'] ?? '',
      nomeServico: map['nomeServico'] ?? '',
      descricaoServico: map['descricaoServico'] ?? '',
      tipoServico: map['tipoServico'] ?? 'Regular',
      // Garante que valores inteiros sejam lidos como double
      valorCobrado: (map['valorCobrado'] ?? 0.0).toDouble(),
      statusNf: map['statusNf'] ?? 'Pendente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numeroOs': numeroOs,
      'dataServico': Timestamp.fromDate(dataServico),
      'empresa': empresa,
      'nomeServico': nomeServico,
      'descricaoServico': descricaoServico,
      'tipoServico': tipoServico,
      'valorCobrado': valorCobrado,
      'statusNf': statusNf,
    };
  }
}