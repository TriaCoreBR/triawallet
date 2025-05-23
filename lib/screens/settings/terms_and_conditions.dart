import 'package:flutter/material.dart';
import 'package:triacore_mobile/widgets/appbar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TriacoreAppBar(title: "Termos de uso"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Termos de Uso",
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
              "Bem-vindo à Tria",
              "Ao utilizar nosso aplicativo, você concorda com estes termos e condições de uso. Este documento estabelece as regras e diretrizes para a utilização da Tria, uma carteira digital descentralizada voltada para transações com ativos digitais e integração com o sistema DEPIX.",
            ),
            SizedBox(height: 16),
            _buildSection("1. Responsabilidades do Usuário", """
a) O usuário é o único responsável por manter sua frase de recuperação segura. A perda dessa frase resulta na perda permanente de acesso à carteira e aos ativos. A Tria não armazena nem tem acesso a essas informações.

b) Ao utilizar a carteira ou o modo de comércio via DEPIX, o usuário aceita integralmente os termos e se responsabiliza pelas operações realizadas, sejam próprias ou de terceiros.

c) Ao efetuar pagamentos via PIX, o usuário adquire a stablecoin DEPIX, lastreada em reais tokenizados. Os valores são recebidos já líquidos das taxas aplicáveis.

d) Todas as transações via PIX representam a tokenização de reais em DEPIX, realizada dentro da Liquid Network.

e) Quando o usuário opta por receber em USDT Liquid, Bitcoin On-chain ou Liquid Bitcoin (L-BTC), a conversão ocorre automaticamente na carteira. A Tria e suas integradoras não realizam câmbio, apenas viabilizam a conversão via tokenização."""),
            SizedBox(height: 16),
            _buildSection("2. Limitação de Responsabilidade", """
A Tria não se responsabiliza por quaisquer perdas decorrentes do uso do aplicativo, incluindo (mas não se limitando a) falhas de rede, transações não confirmadas, erros do usuário ou perda de acesso às chaves privadas. O uso do app é por conta e risco exclusivo do usuário."""),
            SizedBox(height: 16),
            _buildSection("3. Cotações de Ativos", """
As cotações utilizadas são obtidas de fontes como Bitfinex, Blockchain.com, Binance, CoinGecko, entre outras, sempre buscando a cotação mais atual. Esses valores podem incluir spread, especialmente em situações de compra direta ou uso comercial."""),
            SizedBox(height: 16),
            _buildSection("4. Serviços", """
a) Taxas de Rede e de Serviço:
As taxas totais aplicadas pela Tria consideram:

- A rede do ativo utilizado (ex: taxa on-chain, taxas da Liquid, etc.);
- Custos com intermediários das processadoras de pagamento via PIX;
- As cotações exibidas já incluem todos os custos envolvidos.

b) Confirmação e Recebimento:
Em caso de falhas, atrasos ou inconsistências nas transações PIX, o usuário deve contatar o suporte por meio do site oficial: https://triacore.pro.

A Tria atualmente opera exclusivamente com as redes Bitcoin On-chain e Liquid Network. As transações são protegidas contra rastreamento utilizando a estrutura de confidencialidade da Liquid Network. Mesmo quando o cliente opta por receber em Bitcoin On-chain, a origem dos fundos permanece na Liquid, garantindo anonimato e privacidade."""),
            SizedBox(height: 16),
            _buildSection("5. Pagamentos em Reais (Fiat)", """
O único método de pagamento aceito na Tria é o PIX. Como medida de segurança, transações iniciais possuem limites reduzidos. Há um limite diário de R\$5.000,00 por CPF ou CNPJ, compartilhado entre todos os aplicativos que utilizam a infraestrutura DEPIX. Caso esse limite seja ultrapassado, a transação poderá ser estornada automaticamente pelas processadoras. Esse controle atende às normas das processadoras, com o objetivo de mitigar riscos de lavagem de dinheiro, mantendo a privacidade e segurança do ecossistema DEPIX."""),
            SizedBox(height: 24),
            Text(
              "Data da última atualização: 07/05/2025",
              style: TextStyle(
                fontFamily: "roboto",
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
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
          Text(content, style: TextStyle(fontSize: 16, fontFamily: "roboto")),
        ],
      ),
    );
  }
}
