import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/empresa_model.dart';
import '../../providers/empresa_provider.dart';

class EmpresasListView extends StatefulWidget {
  const EmpresasListView({super.key});

  @override
  State<EmpresasListView> createState() => _EmpresasListViewState();
}

class _EmpresasListViewState extends State<EmpresasListView> {
  void _mostrarDialogoNovaEmpresa() {
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Nova Empresa', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nomeController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Nome do cliente/empresa',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD85A36))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A36)),
              onPressed: () async {
                final nome = nomeController.text;
                if (nome.isNotEmpty) {
                  await context.read<EmpresaProvider>().adicionarEmpresa(nome);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // NOVO: Modal Visual de Edição
  void _mostrarDialogoEditarEmpresa(Empresa empresa) {
    final nomeController = TextEditingController(text: empresa.nome);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Editar Empresa', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nomeController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nome da Empresa',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A36)),
            onPressed: () async {
              await context.read<EmpresaProvider>().editarEmpresa(empresa.id, nomeController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ATUALIZAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(Empresa empresa) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Excluir Empresa', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza que deseja excluir "${empresa.nome}"?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () async {
                await context.read<EmpresaProvider>().removerEmpresa(empresa.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('EXCLUIR', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmpresaProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Empresas Clientes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD85A36),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Empresa>>(
        stream: provider.empresasStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFD85A36)));
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar empresas.', style: TextStyle(color: Colors.red)));

          final empresas = snapshot.data ?? [];
          if (empresas.isEmpty) return const Center(child: Text('Nenhuma empresa cadastrada.', style: TextStyle(color: Colors.white54, fontSize: 16)));

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: empresas.length,
            itemBuilder: (context, index) {
              final empresa = empresas[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFF2A2A2A), child: Icon(Icons.business, color: Color(0xFF39FF14))),
                  title: Text(empresa.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  // NOVO: Row contendo os botões Editar e Excluir
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _mostrarDialogoEditarEmpresa(empresa),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white54),
                        onPressed: () => _confirmarExclusao(empresa),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF39FF14),
        foregroundColor: const Color(0xFF121212),
        onPressed: _mostrarDialogoNovaEmpresa,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}