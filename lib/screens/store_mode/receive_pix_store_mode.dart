/*
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/asset_catalog.dart';
import 'package:triacore_mobile/models/assets.dart';
import 'package:triacore_mobile/models/payments.dart';
import 'package:triacore_mobile/models/user.dart';
import 'package:triacore_mobile/providers/triacore/user_provider.dart';
import 'package:triacore_mobile/providers/wallet/liquid_provider.dart';
import 'package:triacore_mobile/screens/generate_pix_payment_code/generate_pix_payment_code.dart';
import 'package:triacore_mobile/screens/receive_pix/widgets/address_display.dart';
import 'package:triacore_mobile/screens/receive_pix/widgets/amount_input.dart';
import 'package:triacore_mobile/services/triacore/registration.dart';
import 'package:triacore_mobile/services/triacore/user.dart';
import 'package:triacore_mobile/widgets/appbar.dart';
import 'package:triacore_mobile/widgets/swipe_to_confirm.dart';

const BACKEND_URL = String.fromEnvironment(
  "BACKEND_URL",
  defaultValue: "basetria.xyz",
);

class ReceivePixScreen extends ConsumerStatefulWidget {
  const ReceivePixScreen({Key? key}) : super(key: key);

  @override
  ReceivePixState createState() => ReceivePixState();
}

class ReceivePixState extends ConsumerState<ReceivePixScreen> {
    extends ConsumerState<ReceivePixStoreModeScreen> {
  // depix as default asset
  Asset selectedAsset = AssetCatalog.getById("depix")!;
  late Future<String?> _addressFuture;
  late Future<User?> _userFuture;
  // Controller for the BRL amount input
  final TextEditingController amountController = TextEditingController();

  double _currentAmountFloat = 0.0;
  int _currentAmountInCents = 0;
  User? userDetails;

  late Key dropdownKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _addressFuture =
        ref.read(liquidWalletNotifierProvider.notifier).generateAddress();

    _userFuture = _preloadUserData();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // Handle text changes directly
  void _handleTextChanged(String text) {
    // Replace comma with dot for proper parsing
    final normalizedText = text.replaceAll(',', '.');
    final newAmount =
        normalizedText.isNotEmpty
            ? double.tryParse(normalizedText) ?? 0.0
            : 0.0;

    if (newAmount != _currentAmountFloat) {
      setState(() {
        _currentAmountFloat = newAmount;
        // Convert to cents: multiply by 100 and round to integer
        _currentAmountInCents = (newAmount * 100).round();
      });
    }
  }

  void _onAssetChanged(Asset? asset) {
    if (asset == null) {
      return;
    }

    if (asset.id != "depix" && asset.id != "lbtc") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Em breve.")));

      setState(() {
        selectedAsset = AssetCatalog.getById("depix")!;
        dropdownKey = UniqueKey();
      });
    } else {
      setState(() {
        selectedAsset = asset;
      });
    }
  }

  Future<bool> validateUserInput(int amount) async {
    final userService = ref.read(userServiceProvider);
    final user = await userService.getUserDetails();

    if (!mounted) return false;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível conectar ao servidor.")),
      );
      return false;
    }

    if (amount > user.allowedSpending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Limite de transação excedido.")),
      );
      return false;
    }

    if (amount < 20 * 100 || amount > 5000 * 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, insira um valor entre R\$ 20,00 e R\$ 5.000,00.",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<User?> _preloadUserData() async {
    final userService = UserService(backendUrl: BACKEND_URL);
    final userId = await userService.getUserId();

    if (userId == null) {
      final registrationService = RegistrationService(backendUrl: BACKEND_URL);
      final newUserId = await registrationService.registerUser(null);

      if (newUserId == null) {
        debugPrint("Failed to register user");
      }

      await registrationService.saveUserId(newUserId!);
    }

    return await userService.getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final liquidWalletState = ref.watch(liquidWalletNotifierProvider);
    final liquidAssets = AssetCatalog.liquidAssets;

    return Scaffold(
      appBar: TriacoreAppBar(title: "Comprar com PIX"),
      body: liquidWalletState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) =>
                Center(child: Text("Erro ao instanciar carteira: $err")),
        data:
            (_) => FutureBuilder<String?>(
              future: _addressFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao gerar endereço: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text("Nenhum endereço disponível"),
                  );
                }

                final address = snapshot.data!;

                return FutureBuilder<User?>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      log("${snapshot.error!}");
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              "Não foi possível conectar ao servidor. Tente novamente mais tarde",
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          PixInputAmount(
                            amountController: amountController,
                            onChanged: _handleTextChanged,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "• Valor mínimo: R\$ 20,00 \n• Limite diário por CPF/CNPJ: R\$ 5.000,00",
                                style: TextStyle(
                                  fontFamily: "roboto",
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Limite diário"),
                                          scrollable: true,
                                          content: Text("""
O limite de pagamento via PIX na Triacore é compartilhado com outras plataformas que utilizam o sistema DEPIX, incluindo compras P2P ou concorrentes. Esse limite é monitorado pelas processadoras de pagamento por meio do sistema PIX do BACEN, com base no CPF ou CNPJ vinculado ao DEPIX. Assim, ao atingir o teto diário de R\$5.000 em transações realizadas fora da Triacore, novas tentativas de pagamento via nossos QR Codes serão automaticamente bloqueadas e estornadas à conta de origem.
Essa limitação protege o usuário contra a obrigatoriedade de reporte automático de transações. Nem a Triacore nem as processadoras realizam comunicação compulsória dessas operações, preservando a sua privacidade.
                                        """),
                                        ),
                                  );
                                },
                                child: Icon(
                                  Icons.question_mark,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AddressDisplay(
                              address: address,
                              fiatAmount: _currentAmountInCents,
                              asset: selectedAsset,
                            ),
                          ),
                          if (MediaQuery.of(context).viewInsets.bottom == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: SwipeToConfirm(
                                onConfirm: () async {
                                  final result = await validateUserInput(
                                    _currentAmountInCents,
                                  );

                                  if (!result) return;

                                  final pixTransaction = PixTransaction(
                                    address: address,
                                    brlAmount: _currentAmountInCents,
                                    asset:
                                        selectedAsset.liquidAssetId ??
                                        "02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189",
                                  );

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) => GeneratePixPaymentCodeScreen(
                                              pixTransaction: pixTransaction,
                                              assetId:
                                                  selectedAsset.liquidAssetId!,
                                            ),
                                      ),
                                    );
                                  }
                                },
                                text: "Deslize para pagar",
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                progressColor:
                                    Theme.of(context).colorScheme.secondary,
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                width: 300,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}

*/
