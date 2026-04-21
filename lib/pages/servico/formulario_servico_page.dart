import 'package:flutter/material.dart';
import '../../models/servico_model.dart';
import '../../repositories/servico_repository.dart';

class FormularioServicoPage extends StatefulWidget {
  const FormularioServicoPage({super.key});

  @override
  State<FormularioServicoPage> createState() => _FormularioServicoPageState();
}

class _FormularioServicoPageState extends State<FormularioServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final ServicoRepository _repository = ServicoRepository();

  // Opções para a empresa (mockadas, mas no futuro podem vir do banco)
  final List<String> _empresas = ['Metalúrgica Alpha', 'Tornos Beta', 'Usinagem Gamma', 'Outra'];
  
  String? _empresaSelecionada;
  String _tipoServico = 'Regular';
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _isLoading = false;

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final novoServico = Servico(
        empresa: _empresaSelecionada!,
        descricaoServico: _descricaoController.text.trim(),
        dataServico: DateTime.now(), // Registra a hora exata da criação
        valorCobrado: double.parse(_valorController.text.replaceAll(',', '.')),
        tipoServico: _tipoServico,
      );

      await _repository.addServico(novoServico);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço registrado com sucesso!')),
        );
        Navigator.pop(context); // Volta para a HomePage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Serviço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Empresa Cliente',
                  border: OutlineInputBorder(),
                ),
                value: _empresaSelecionada,
                items: _empresas.map((empresa) {
                  return DropdownMenuItem(value: empresa, child: Text(empresa));
                }).toList(),
                onChanged: (value) => setState(() => _empresaSelecionada = value),
                validator: (value) => value == null ? 'Selecione uma empresa' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da Manutenção/Peça',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Descreva o serviço' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor Cobrado (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Serviço',
                  border: OutlineInputBorder(),
                ),
                value: _tipoServico,
                items: ['Regular', 'Emergencial'].map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (value) => setState(() => _tipoServico = value!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarServico,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SALVAR SERVIÇO', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}