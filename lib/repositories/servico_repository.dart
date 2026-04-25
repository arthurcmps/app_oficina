import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/servico_model.dart';

class ServicoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Busca em tempo real de serviços, ordenando pelos mais recentes
  Stream<List<Servico>> getServicosStream() {
    return _firestore
        .collection(_collection)
        .orderBy('dataServico', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servico.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Adiciona o serviço gerando a OS automaticamente
  Future<void> addServico(Servico servico) async {
    final String datePart = DateFormat('yyyyMMdd').format(DateTime.now());
    
    // Busca a última OS criada hoje para definir o próximo sequencial
    final query = await _firestore
        .collection(_collection)
        .where('numeroOs', isGreaterThanOrEqualTo: 'OS-$datePart-')
        .where('numeroOs', isLessThan: 'OS-$datePart-\uf8ff') // Filtro de string avançado
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

    // Cria o map base e sobrescreve o numeroOs com o valor gerado
    final mapData = servico.toMap();
    mapData['numeroOs'] = generatedOs;

    await _firestore.collection(_collection).add(mapData);
  }

  // Função extra útil para atualizar apenas o status da NF
  Future<void> updateStatusNf(String id, String novoStatus) async {
    await _firestore.collection(_collection).doc(id).update({
      'statusNf': novoStatus,
    });
  }
}