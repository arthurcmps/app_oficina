import 'package:url_launcher/url_launcher.dart';
import '../models/servico_model.dart';
import 'package:intl/intl.dart';

class WhatsAppHelper {
  static Future<void> compartilharServico(Servico servico) async {
    // Formatação da data e do valor monetário para o padrão brasileiro
    final dataFormatada = DateFormat('dd/MM/yyyy').format(servico.dataServico);
    final valorFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
        .format(servico.valorCobrado);

    // Montagem da mensagem estruturada
    final mensagem = '''
🛠 *Novo Serviço Registrado*
🏢 *Empresa:* ${servico.empresa}
📅 *Data:* $dataFormatada
⚙️ *Serviço:* ${servico.descricaoServico}
⚠️ *Tipo:* ${servico.tipoServico}
💰 *Valor:* $valorFormatado
📄 *Status NF:* ${servico.statusNf}
''';

    // Codificando o texto para o formato de URL
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(mensagem)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Não foi possível abrir o WhatsApp. Ele está instalado?';
      }
    } catch (e) {
      // Em um app de produção, você pode usar um logger aqui
      print('Erro ao lançar WhatsApp: $e');
    }
  }
}