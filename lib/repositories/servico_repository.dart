import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/servico_model.dart';

class ServicoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  Stream<List<Servico>> getServicosStream() {
    return _firestore
        .collection(_collection)
        .orderBy('dataServico', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servico.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addServico(Servico servico) async {
    final String datePart = DateFormat('yyyyMMdd').format(DateTime.now());
    
    final query = await _firestore
        .collection(_collection)
        .where('numeroOs', isGreaterThanOrEqualTo: 'OS-$datePart-')
        .where('numeroOs', isLessThan: 'OS-$datePart-\uf8ff')
        .orderBy('numeroOs', descending: true)
        .limit(1)
        .get();

    int nextSeq = 1;
    if (query.docs.isNotEmpty) {
      final lastOs = query.docs.first.data()['numeroOs'] as String;
      final lastSeqStr = lastOs.split('-').last;
      nextSeq = (int.tryParse(lastSeqStr) ?? 0) + 1;
    }

    final String seqPart = nextSeq.toString().padLeft(3, '0');
    final String generatedOs = 'OS-$datePart-$seqPart';

    final mapData = servico.toMap();
    mapData['numeroOs'] = generatedOs;

    await _firestore.collection(_collection).add(mapData);
  }

  // NOVO: Atualizar OS Completa
  Future<void> updateServico(Servico servico) async {
    await _firestore.collection(_collection).doc(servico.id).update(servico.toMap());
  }

  // NOVO: Deletar OS
  Future<void> deleteServico(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> updateStatusNf(String id, String novoStatus) async {
    await _firestore.collection(_collection).doc(id).update({'statusNf': novoStatus});
  }

  Future<void> updateDataServico(String id, DateTime novaData) async {
    await _firestore.collection(_collection).doc(id).update({
      'dataServico': Timestamp.fromDate(novaData),
    });
  }
}