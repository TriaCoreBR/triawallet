import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:triacore_mobile/screens/create_wallet/widgets/mnemonic_display.dart';
import 'package:triacore_mobile/widgets/appbar.dart';
import 'package:triacore_mobile/widgets/buttons.dart';
import 'package:no_screenshot/no_screenshot.dart';

class ViewMnemonicScreen extends StatelessWidget {
  final String mnemonic;
  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  ViewMnemonicScreen({super.key, required this.mnemonic});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        await _noScreenshot.screenshotOn();
      },
      child: Scaffold(
        appBar: TriacoreAppBar(title: "Sua frase de recuperação"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ATENÇÃO",
                      style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Anote estas palavras em ordem e guarde-as em local seguro.",
                      style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Esta é a única forma de recuperar sua carteira em caso de perda do dispositivo.",
                      style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              MnemonicGridDisplay(mnemonic: mnemonic),
              Spacer(),
              PrimaryButton(
                text: "Copiar seeds",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: mnemonic));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Frase copiada para a área de transferência",
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
