import 'package:flutter/material.dart';
import 'package:triacore_mobile/screens/pin/verify_pin.dart';
import 'package:triacore_mobile/screens/receive_pix/receive_pix.dart';
import 'package:triacore_mobile/screens/store_mode/store_screen.dart';
import 'package:triacore_mobile/screens/wallet/wallet.dart';
import 'package:triacore_mobile/services/auth.dart';
import 'package:triacore_mobile/utils/store_mode.dart';
import 'package:triacore_mobile/widgets/buttons.dart';

class StoreHomeScreen extends StatefulWidget {
  StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => StoreHomeState();
}

class StoreHomeState extends State<StoreHomeScreen> {
  late final StoreModeHandler _storeModeHandler = StoreModeHandler();

  Future<void> _initStoreMode() async {
    final authService = AuthenticationService();
    await _storeModeHandler.setStoreMode(true);
    await authService.invalidateSession();
  }

  @override
  void initState() {
    super.initState();
    _initStoreMode();
  }

  void _onReturnWalletTap(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WalletScreen()),
    );

    await _storeModeHandler.setStoreMode(false);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.white, fontSize: 16.0);
    TextStyle linkStyle = TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16.0);

    final buttons = Column(
      children: [
        PrimaryButton(
          text: "Store",
          onPressed: () {
            print('Botão Nova Venda pressionado');
            try {
              print('Navegando para StoreScreen');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoreScreen()),
              ).then((_) {
                print('Navegação concluída');
              }).catchError((error) {
                print('Erro na navegação: $error');
              });
            } catch (e) {
              print('Erro ao navegar: $e');
            }
          },
          icon: Icons.shopping_cart,
        ),
        SizedBox(height: 20),
        PrimaryButton(
          text: "Receber Pagamento",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReceivePixScreen()),
            );
          },
          icon: Icons.payment,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Acessar Carteira.", style: defaultStyle),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => VerifyPinScreen(
                          onPinConfirmed: () async {
                            _onReturnWalletTap(context);
                          },
                          forceAuth: true,
                        ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(" Clique aqui.", style: linkStyle),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: linkStyle.color),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/triacore-logo.png', width: 200, height: 200),
          SizedBox(height: 50),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(children: [buttons]),
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(padding: const EdgeInsets.all(16.0), child: body),
      ),
    );
  }
}
