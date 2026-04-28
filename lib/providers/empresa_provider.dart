import 'package:flutter/material.dart';
import '../models/empresa_model.dart';
import '../repositories/empresa_repository.dart';

class EmpresaProvider extends ChangeNotifier {
  final EmpresaRepository _repository = EmpresaRepository();

  // Expõe a Stream para que a UI reaja automaticamente a mudanças no banco
  Stream<List<Empresa>> get empresasStream => _repository.getEmpresasStream();

  Future<void> adicionarEmpresa(String nome) async {
    if (nome.trim().isEmpty) return;
    await _repository.addEmpresa(nome.trim());
  }

  Future<void> removerEmpresa(String id) async {
    await _repository.deleteEmpresa(id);
  }

  Future<void> editarEmpresa(String id, String novoNome) async {
  if (novoNome.trim().isEmpty) return;
  await _repository.updateEmpresa(id, novoNome.trim());
  }
}