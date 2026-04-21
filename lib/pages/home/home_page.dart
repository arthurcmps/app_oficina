import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../repositories/servico_repository.dart';
import '../../models/servico_model.dart';
import '../../utils/whatsaap_helper.dart'; 
import '../servico/formulario_servico_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ServicoRepository _repository = ServicoRepository();
  String _termoPesquisa = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async => await authService.logout(),
            tooltip: 'Sair do Sistema',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por empresa ou serviço...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _termoPesquisa = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Servico>>(
        stream: _repository.getServicosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar serviços.'));
          }

          final servicos = snapshot.data ?? [];
          
          final servicosFiltrados = servicos.where((s) {
            return s.empresa.toLowerCase().contains(_termoPesquisa) ||
                   s.descricaoServico.toLowerCase().contains(_termoPesquisa);
          }).toList();

          if (servicosFiltrados.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: servicosFiltrados.length,
            itemBuilder: (context, index) {
              final servico = servicosFiltrados[index];
              final dataFormatada = DateFormat('dd/MM/yyyy').format(servico.dataServico);
              final valorFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                  .format(servico.valorCobrado);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    servico.empresa, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(servico.descricaoServico),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(dataFormatada),
                          const Spacer(),
                          Text(
                            valorFormatado,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: servico.tipoServico == 'Emergencial' ? Colors.red[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          servico.tipoServico,
                          style: TextStyle(
                            fontSize: 12,
                            color: servico.tipoServico == 'Emergencial' ? Colors.red[900] : Colors.blue[900],
                          ),
                        ),
                      )
                    ],
                  ),
                  trailing: IconButton(
                    // CORREÇÃO: Usando um ícone nativo do Flutter (balão de chat)
                    icon: const Icon(Icons.chat, color: Colors.green),
                    onPressed: () => WhatsAppHelper.compartilharServico(servico),
                    tooltip: 'Compartilhar no WhatsApp',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioServicoPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}