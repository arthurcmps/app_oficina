import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/empresa_model.dart';
import '../../models/servico_model.dart';
import '../../providers/empresa_provider.dart';
import '../../providers/servico_provider.dart';

class ServicoFormView extends StatefulWidget {
  final Servico? servicoParaEditar; // Parâmetro opcional

  const ServicoFormView({super.key, this.servicoParaEditar});

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
  void initState() {
    super.initState();
    // Se estiver editando, preenche os campos
    if (widget.servicoParaEditar != null) {
      _empresaSelecionada = widget.servicoParaEditar!.empresa;
      _tipoServico = widget.servicoParaEditar!.tipoServico;
      _nomeController.text = widget.servicoParaEditar!.nomeServico;
      _descricaoController.text = widget.servicoParaEditar!.descricaoServico;
      _valorController.text = widget.servicoParaEditar!.valorCobrado.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _empresaSelecionada == null) return;

    setState(() => _isLoading = true);

    final servico = Servico(
      id: widget.servicoParaEditar?.id ?? '',
      numeroOs: widget.servicoParaEditar?.numeroOs ?? '',
      dataServico: widget.servicoParaEditar?.dataServico ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      empresa: _empresaSelecionada!,
      nomeServico: _nomeController.text.trim(),
      descricaoServico: _descricaoController.text.trim(),
      tipoServico: _tipoServico,
      valorCobrado: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
      statusNf: widget.servicoParaEditar?.statusNf ?? 'Pendente',
    );

    if (widget.servicoParaEditar == null) {
      await context.read<ServicoProvider>().adicionarServico(servico);
    } else {
      await context.read<ServicoProvider>().editarServico(servico);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: Text(widget.servicoParaEditar == null ? 'Nova OS' : 'Editar ${widget.servicoParaEditar!.numeroOs}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StreamBuilder<List<Empresa>>(
                stream: context.read<EmpresaProvider>().empresasStream,
                builder: (context, snapshot) {
                  final empresas = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF22262B),
                    value: _empresaSelecionada,
                    decoration: _inputDecoration('Empresa Cliente'),
                    items: empresas.map((e) => DropdownMenuItem(value: e.nome, child: Text(e.nome))).toList(),
                    onChanged: (val) => setState(() => _empresaSelecionada = val),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _nomeController, decoration: _inputDecoration('Nome do Serviço'), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              TextFormField(controller: _descricaoController, maxLines: 3, decoration: _inputDecoration('Descrição Técnica'), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF22262B),
                value: _tipoServico,
                decoration: _inputDecoration('Tipo'),
                items: ['Regular', 'Emergencial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _tipoServico = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _valorController, keyboardType: TextInputType.number, decoration: _inputDecoration('Valor (R\$)'), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvar,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('SALVAR ALTERAÇÕES'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFF22262B));
}