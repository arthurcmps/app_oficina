import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/servico_model.dart';
import '../../providers/servico_provider.dart';
import '../../providers/auth_provider.dart';
import '../servicos/servico_form_view.dart';
import '../empresas/empresas_list_view.dart';
import '../auth/login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _termoBusca = '';
  String _filtroStatus = 'Todos';
  String _filtroTipo = 'Todos';
  DateTimeRange? _intervaloDatas;

  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatadorData = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> _compartilharWhatsApp(Servico servico) async {
    final mensagem = "⚙️ *FORJA ERP - Ordem de Serviço*\n\n"
        "🛠️ *OS:* ${servico.numeroOs}\n"
        "🏢 *Empresa:* ${servico.empresa}\n"
        "🔧 *Serviço:* ${servico.nomeServico}\n"
        "⚠️ *Tipo:* ${servico.tipoServico}\n"
        "💰 *Valor:* ${formatadorMoeda.format(servico.valorCobrado)}\n\n"
        "Por favor, emitir a Nota Fiscal. Status atual: ${servico.statusNf}";

    final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(mensagem)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _alternarStatusNf(Servico servico) async {
    final novoStatus = servico.statusNf == 'Pendente' ? 'Emitida' : 'Pendente';
    
    await context.read<ServicoProvider>().atualizarStatusNf(servico.id, novoStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status da NF da ${servico.numeroOs} atualizado para: $novoStatus'),
          backgroundColor: novoStatus == 'Emitida' ? Colors.blue : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _fazerLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Painel de Serviços', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD85A36),
        actions: [
          IconButton(
            icon: const Icon(Icons.business, color: Colors.white),
            tooltip: 'Gerenciar Empresas',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmpresasListView())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _fazerLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar OS, Empresa ou Serviço...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD85A36)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _termoBusca = val.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF2A2A2A),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Status NF', labelStyle: TextStyle(color: Colors.white54)),
                        value: _filtroStatus,
                        items: ['Todos', 'Pendente', 'Emitida'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _filtroStatus = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF2A2A2A),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.white54)),
                        value: _filtroTipo,
                        items: ['Todos', 'Regular', 'Emergencial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _filtroTipo = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFD85A36),
                            onPrimary: Colors.white,
                            surface: Color(0xFF1E1E1E),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (range != null) setState(() => _intervaloDatas = range);
                  },
                  icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF39FF14)),
                  label: Text(
                    _intervaloDatas == null 
                      ? 'Filtrar por Data' 
                      : '${formatadorData.format(_intervaloDatas!.start).split(' ')[0]} - ${formatadorData.format(_intervaloDatas!.end).split(' ')[0]}',
                  ),
                ),
                if (_intervaloDatas != null)
                  TextButton(
                    onPressed: () => setState(() => _intervaloDatas = null),
                    child: const Text('Limpar Filtro de Data', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Servico>>(
              stream: context.read<ServicoProvider>().servicosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFD85A36)));
                if (snapshot.hasError) return const Center(child: Text('Erro ao carregar serviços.', style: TextStyle(color: Colors.red)));

                var servicos = snapshot.data ?? [];

                servicos = servicos.where((s) {
                  final buscaMatch = s.numeroOs.toLowerCase().contains(_termoBusca) ||
                                     s.empresa.toLowerCase().contains(_termoBusca) ||
                                     s.nomeServico.toLowerCase().contains(_termoBusca);
                  final statusMatch = _filtroStatus == 'Todos' || s.statusNf == _filtroStatus;
                  final tipoMatch = _filtroTipo == 'Todos' || s.tipoServico == _filtroTipo;
                  bool dataMatch = true;
                  if (_intervaloDatas != null) {
                    dataMatch = s.dataServico.isAfter(_intervaloDatas!.start.subtract(const Duration(seconds: 1))) &&
                                s.dataServico.isBefore(_intervaloDatas!.end.add(const Duration(days: 1)));
                  }
                  return buscaMatch && statusMatch && tipoMatch && dataMatch; // CORRIGIDO AQUI
                }).toList();

                if (servicos.isEmpty) return const Center(child: Text('Nenhum serviço encontrado.', style: TextStyle(color: Colors.white54)));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    final servico = servicos[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                        side: BorderSide(color: servico.tipoServico == 'Emergencial' ? Colors.red.withOpacity(0.5) : Colors.transparent)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(servico.numeroOs, style: const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold, fontSize: 16)),
                                // NOVO: Bloco de Data + Botão de Edição
                                Row(
                                  children: [
                                    Text(formatadorData.format(servico.dataServico), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    IconButton(
                                      icon: const Icon(Icons.edit_calendar, size: 16, color: Color(0xFFD85A36)),
                                      onPressed: () async {
                                        final novaData = await showDatePicker(
                                          context: context,
                                          initialDate: servico.dataServico,
                                          firstDate: DateTime(2023),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                        );
                                        if (novaData != null && context.mounted) {
                                          context.read<ServicoProvider>().atualizarDataServico(servico.id, novaData);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF2A2A2A), height: 24),
                            Text(servico.empresa, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(servico.nomeServico, style: const TextStyle(color: Colors.white70)),
                            if (servico.descricaoServico.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF121212), 
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF2A2A2A)),
                                ),
                                child: Text(
                                  servico.descricaoServico,
                                  style: const TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Valor: ${formatadorMoeda.format(servico.valorCobrado)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _alternarStatusNf(servico),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: servico.statusNf == 'Emitida' ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: servico.statusNf == 'Emitida' ? Colors.blue : Colors.orange),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(servico.statusNf == 'Emitida' ? Icons.check_circle : Icons.pending, size: 14, color: servico.statusNf == 'Emitida' ? Colors.blue : Colors.orange),
                                            const SizedBox(width: 6),
                                            Text('NF: ${servico.statusNf}', style: TextStyle(color: servico.statusNf == 'Emitida' ? Colors.blue : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send_rounded, color: Color(0xFF39FF14), size: 32),
                                  onPressed: () => _compartilharWhatsApp(servico),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD85A36),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicoFormView())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}