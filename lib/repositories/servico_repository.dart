import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/servico_model.dart';

class ServicoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'services';

  ServicoRepository() {
    // Garante que o cache offline esteja ativado
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  // Obter stream de serviços (Atualização em tempo real)
  Stream<List<Servico>> getServicosStream() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('dataServico', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Servico.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Adicionar um novo serviço
  Future<void> addServico(Servico servico) async {
    await _firestore.collection(_collectionPath).add(servico.toMap());
  }

  // Atualizar um serviço existente
  Future<void> updateServico(Servico servico) async {
    if (servico.id != null) {
      await _firestore
          .collection(_collectionPath)
          .doc(servico.id)
          .update(servico.toMap());
    }
  }

  // Deletar um serviço
  Future<void> deleteServico(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}