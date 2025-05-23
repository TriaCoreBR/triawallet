import 'package:flutter/material.dart';
import 'package:triacore_mobile/widgets/appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TriacoreAppBar(title: "Política de Privacidade"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Política de Privacidade - Tria",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: "roboto",
              ),
            ),
            Text(
              "Última atualização: 07/05/2025",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: "roboto",
              ),
            ),
            SizedBox(height: 16),
            _buildSection(
              "1. Identificação do Desenvolvedor",
              "Responsável: Tria Core Tecnologia Ltda.\nEndereço: Rua Exemplo, 123, São Paulo, SP, Brasil\nE-mail para contato: saque@triacore.pro",
            ),
            SizedBox(height: 16),
            _buildSection(
              "2. Escopo e Definições",
              "Esta Política se aplica a todos os usuários do site, aplicativo Tria Core e integrações de terceiros.\n\nUsuário: Qualquer pessoa que utilize o site, o aplicativo Tria Core ou interaja com integrações de terceiros.\n\nInformações Pessoais: Dados que possam identificar alguém, como nome, e-mail ou CPF, mesmo que combinados com outras informações.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "3. Coleta e Uso de Informações",
              "A Tria Core não coleta, armazena nem compartilha dados pessoais sensíveis dos usuários, tais como:\n\n- Nome completo\n- E-mail\n- Telefone\n- Dados pessoais\n- Documentos pessoais\n- Endereço residencial\n\nA carteira Tria Core é construída com foco em privacidade total. Todos os dados permanecem armazenados localmente no dispositivo do usuário.\n\nIntegração com o sistema PIX:\n\nA Tria Core não armazena dados de transações via PIX. Informações como nome do pagador, CPF ou chave PIX são processadas exclusivamente pelas intermediadoras, conforme as normas do Banco Central e respeitando o sigilo das operações de PIX.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "4. Cookies, Conexões e Serviços de Terceiros",
              "Não utilizamos cookies nem rastreadores no aplicativo.\nO app pode se conectar a serviços da Tria Core ou de terceiros para consultar dados de blockchain (como saldos e taxas), sempre de forma anônima, segura e criptografada (HTTPS/TLS).\n\nO uso de sites, ferramentas, fóruns e redes sociais vinculadas à Tria Core pode envolver o tráfego de dados fora do nosso controle, como por exemplo:\n\n- Exploradores de blockchain\n- Formulários externos\n- Plataformas de atendimento ou redes sociais\n\nRecomendação: Revise as políticas de privacidade dos serviços de terceiros para garantir compreensão sobre o uso e proteção de seus dados.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "5. Chaves Privadas e Dados Sensíveis",
              "A Tria Core nunca tem acesso às suas chaves privadas, frases-semente (seeds) ou qualquer outro dado sensível da sua carteira. Toda a custódia é exclusivamente do próprio usuário, sem qualquer gerenciamento ou envolvimento da Tria Core ou de terceiros.\n\nAtenção: Em caso de perda das chaves, não há possibilidade de recuperação dos ativos. A responsabilidade pelo backup e proteção é inteiramente do usuário, conforme destacado nos Termos de Uso.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "6. Comunicação com a Tria Core",
              "Ao entrar em contato conosco de forma voluntária (por exemplo, para solicitar saques de DEPIX ou suporte), os dados eventualmente compartilhados (nome, e-mail, CPF, dados bancários ou chaves PIX) são tratados com o máximo de proteção, sob camadas de criptografia e acesso restrito.\n\nEssas informações são mantidas apenas pelo tempo necessário para atendimento da solicitação e podem ser excluídas mediante pedido do usuário pelo canal de contato.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "7. Segurança das Informações",
              "Adotamos práticas técnicas e administrativas para proteger todos os dados trafegados nos sistemas da Tria Core, incluindo:\n\n- Armazenamento seguro em servidores protegidos\n- Acesso restrito a informações confidenciais\n- Parcerias com serviços que seguem rigorosos padrões de segurança digital\n- Todas as conexões externas são criptografadas (HTTPS/TLS)\n\nApesar de nossos esforços, nenhum sistema é totalmente invulnerável, mas seguimos continuamente as melhores práticas disponíveis.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "8. Direitos do Usuário",
              "O usuário pode, a qualquer momento, solicitar informações, esclarecimentos ou exclusão de eventuais dados fornecidos voluntariamente, entrando em contato pelo e-mail saque@triacore.pro.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "9. Alterações na Política",
              "Esta Política de Privacidade poderá ser atualizada periodicamente.\nEm caso de mudanças significativas que afetem a proteção do usuário, notificações serão disponibilizadas diretamente no site ou aplicativo, e a data de vigência será devidamente atualizada.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "10. Compliance e Conformidade",
              "A Tria Core está comprometida com o cumprimento das legislações vigentes, incluindo a Lei Geral de Proteção de Dados (LGPD) e as políticas do Google Play, adotando medidas técnicas e administrativas para garantir a privacidade, segurança e integridade das informações dos usuários.\nNão promovemos mineração de criptomoedas, jogos de azar, esquemas de pirâmide ou qualquer atividade proibida pela legislação ou pelas políticas da plataforma.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "11. Limitação de Responsabilidade",
              "O uso do aplicativo é de responsabilidade exclusiva do usuário. A Tria Core não se responsabiliza por perdas decorrentes do uso do aplicativo, incluindo falhas de rede, transações não confirmadas, erros do usuário ou perda de acesso às chaves privadas, conforme previsto nos Termos de Uso.",
            ),
            SizedBox(height: 16),
            _buildSection(
              "12. Dúvidas ou Reclamações",
              "Para qualquer dúvida, solicitação ou reclamação relacionada à privacidade e proteção de dados, entre em contato com nosso suporte:\n\n📧 saque@triacore.pro\n🌐 https://triacore.pro",
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "roboto",
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 16, fontFamily: "roboto"),
          ),
        ],
      ),
    );
  }
}
