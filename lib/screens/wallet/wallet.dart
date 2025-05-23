import 'package:lwk/lwk.dart' as liquid;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/assets.dart';
import 'package:triacore_mobile/providers/multichain/owned_assets_provider.dart';
import 'package:triacore_mobile/providers/fiat/fiat_provider.dart';
import 'package:triacore_mobile/screens/wallet/widgets/balance_display.dart';
import 'package:triacore_mobile/screens/wallet/widgets/wallet_buttons.dart';
import 'package:triacore_mobile/widgets/buttons.dart';
import 'package:triacore_mobile/widgets/triacore_drawer.dart';
import 'package:triacore_mobile/screens/wallet/widgets/coin_balance.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  Future<List<liquid.Balance>> getLiquidAssetBalances(
    liquid.Wallet wallet,
  ) async {
    final balances = await wallet.balances();
    return balances;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: const Text(
        "Carteira",
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _toggleBalanceVisibility,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownedAssetsState = ref.watch(ownedAssetsNotifierProvider.future);

    // Altura do menu de navegação do Android
    const double bottomNavigationBarHeight = 56.0;
    
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const TriacoreDrawer(),
      body: FutureBuilder<List<OwnedAsset>>(
        future: ownedAssetsState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          final ownedAssets = snapshot.data!;
          return Stack(
            children: [
              // Conteúdo principal
              Column(
                children: [
                  // Seção do Saldo
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: BalanceDisplay(isBalanceVisible: _isBalanceVisible),
                  ),
                  
                  // Botões de Ação
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        WalletButtonBox(
                          label: "Enviar",
                          icon: Icons.arrow_outward,
                          onTap: () => Navigator.pushNamed(context, "/send_funds"),
                        ),
                        WalletButtonBox(
                          label: "Receber",
                          icon: Icons.call_received,
                          onTap: () => Navigator.pushNamed(context, "/receive_funds"),
                        ),
                        WalletButtonBox(
                          label: "Swap",
                          icon: Icons.swap_horiz,
                          onTap: () => Navigator.pushNamed(context, "/swap"),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lista de Ativos
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        ref.invalidate(ownedAssetsNotifierProvider);
                        return ref.refresh(ownedAssetsNotifierProvider.future);
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: bottomNavigationBarHeight + 16.0, // Espaço para o botão + margem
                        ),
                        itemCount: ownedAssets.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          child: CoinBalance(
                            ownedAsset: ownedAssets[index],
                            isBalanceVisible: _isBalanceVisible,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Botão Comprar fixo na parte inferior
              Positioned(
                left: 60.0,
                right: 60.0,
                bottom: bottomNavigationBarHeight + 35.0, // Ajustado para subir o botão
                child: PrimaryButton(
                  text: "Comprar",
                  onPressed: () => Navigator.pushNamed(context, "/receive_pix"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
