import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empresa_model.dart';

class EmpresaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'empresas';

  // Retorna uma Stream em tempo real das empresas (útil para Listas e Dropdowns)
  Stream<List<Empresa>> getEmpresasStream() {
    return _firestore
        .collection(_collection)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Empresa.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addEmpresa(String nome) async {
    await _firestore.collection(_collection).add({'nome': nome});
  }

  Future<void> deleteEmpresa(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}