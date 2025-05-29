# triacore

<img src="assets/images/triacore-logo.png">
Triacore é uma carteira móvel de criptomoedas desenvolvida em Flutter, com foco em Bitcoin e ativos da Liquid Network, além de integração ao PIX (sistema de pagamentos instantâneos do Brasil).

## Funcionalidades

- **Suporte Multichain**: Compatível com Bitcoin e Liquid Network
- **Integração com PIX**: Permite conversão fácil entre criptomoedas e Real (BRL)
- **Gestão de Ativos**: Visualize e administre diferentes criptomoedas
- **Troca de Tokens**: Faça swaps entre ativos da Liquid Network
- **Modo Loja**: Interface dedicada para comerciantes receberem pagamentos

## Ativos Compatíveis

- Bitcoin (BTC)
- Liquid Bitcoin (L-BTC)
- Depix (DEPIX) na Liquid Network
- Tether USD (USDT) na Liquid Network

## Arquitetura

Triacore utiliza uma arquitetura moderna baseada em Flutter:

- **Flutter & Dart**: Framework e linguagem principal
- **Riverpod**: Gerenciamento de estado
- **BDK** (Bitcoin Development Kit): Funcionalidades de carteira Bitcoin
- **LWK** (Liquid Wallet Kit): Suporte à carteira da Liquid Network
- **Armazenamento Seguro**: Guarda frases-semente e chaves privadas de modo protegido

## Primeiros Passos

### Pré-requisitos

- Flutter SDK (versão 2.10.0 ou superior)
- Dart SDK (versão 2.16.0 ou superior)
- Android Studio ou Xcode para desenvolvimento nativo

### Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/TriaCoreBR/triabank.git
   cd triabank
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Gere o código necessário:
   ```bash
   dart pub run build_runner build --delete-conflicting-outputs
   ```

4. Execute o aplicativo:
   ```bash
   flutter run
   ```

### Compilando para Produção

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Notas de Segurança

- Nunca compartilhe sua frase mnemônica ou PIN com terceiros
- O aplicativo armazena informações sensíveis de forma segura usando recursos nativos do sistema
- Todas as transações são assinadas localmente — as chaves privadas nunca saem do seu dispositivo

## Como Contribuir

Sua colaboração é bem-vinda! Envie um Pull Request seguindo os passos abaixo:

1. Faça um fork do projeto
2. Crie uma branch para sua funcionalidade (`git checkout -b feature/nova-funcionalidade`)
3. Realize seus commits (`git commit -m 'Adiciona nova funcionalidade'`)
4. Envie para o repositório remoto (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está sob a [Licença Pública Geral GNU](LICENSE).

## Agradecimentos

- Equipe do Bitcoin Development Kit (BDK)
- Bull Bitcoin pelas bindings Dart do LWK
- SideSwap pelo sistema de swaps
- mooze-labs/mooze-client pela inspiração e código

