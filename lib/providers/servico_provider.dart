import 'package:flutter/material.dart';
import '../models/servico_model.dart';
import '../repositories/servico_repository.dart';

class ServicoProvider extends ChangeNotifier {
  final ServicoRepository _repository = ServicoRepository();

  Stream<List<Servico>> get servicosStream => _repository.getServicosStream();

  Future<void> adicionarServico(Servico servico) async {
    await _repository.addServico(servico);
  }

  Future<void> atualizarStatusNf(String id, String novoStatus) async {
    await _repository.updateStatusNf(id, novoStatus);
  }

  Future<void> atualizarDataServico(String id, DateTime novaData) async {
    await _repository.updateDataServico(id, novaData);
  }
}