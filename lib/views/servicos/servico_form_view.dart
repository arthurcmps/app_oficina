import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/empresa_model.dart';
import '../../models/servico_model.dart';
import '../../providers/empresa_provider.dart';
import '../../providers/servico_provider.dart';

class ServicoFormView extends StatefulWidget {
  const ServicoFormView({super.key});

  @override
  State<ServicoFormView> createState() => _ServicoFormViewState();
}

class _ServicoFormViewState extends State<ServicoFormView> {
  final _formKey = GlobalKey<FormState>();
  
  String? _empresaSelecionada;
  String _tipoServico = 'Regular';
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate() || _empresaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos e selecione uma empresa.')));
      return;
    }

    setState(() => _isLoading = true);

    final novoServico = Servico(
      id: '', // Gerado no Firestore
      numeroOs: '', // Gerado automaticamente no Repository
      dataServico: DateTime.now(),
      empresa: _empresaSelecionada!,
      nomeServico: _nomeController.text.trim(),
      descricaoServico: _descricaoController.text.trim(),
      tipoServico: _tipoServico,
      valorCobrado: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
    );

    await context.read<ServicoProvider>().adicionarServico(novoServico);

    if (!mounted) return;
    Navigator.pop(context); // Volta para a Home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OS Criada com sucesso!'), backgroundColor: Color(0xFF39FF14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Nova Ordem de Serviço', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD85A36),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown reativo de Empresas
              StreamBuilder<List<Empresa>>(
                stream: context.read<EmpresaProvider>().empresasStream,
                builder: (context, snapshot) {
                  final empresas = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Empresa Cliente',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    value: _empresaSelecionada,
                    items: empresas.map((e) => DropdownMenuItem(value: e.nome, child: Text(e.nome))).toList(),
                    onChanged: (val) => setState(() => _empresaSelecionada = val),
                    validator: (val) => val == null ? 'Selecione uma empresa' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nome do Serviço (ex: Usinagem de Eixo)'),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: _inputDecoration('Descrição técnica detalhada'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Tipo de Serviço'),
                value: _tipoServico,
                items: ['Regular', 'Emergencial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _tipoServico = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Valor Cobrado (R\$)'),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14), // Verde Neon
                    foregroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _salvarServico,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Color(0xFF121212)) 
                      : const Text('SALVAR ORDEM DE SERVIÇO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}