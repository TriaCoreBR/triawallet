import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/screens/pin/verify_pin.dart';
import 'package:triacore_mobile/screens/pin/create_pin.dart';
import 'package:triacore_mobile/screens/settings/view_mnemonic.dart';
import 'package:triacore_mobile/screens/referral_input/referral_input_screen.dart';
import 'package:triacore_mobile/screens/settings/privacy_policy.dart';
import 'package:triacore_mobile/utils/mnemonic.dart';
import 'package:triacore_mobile/widgets/appbar.dart';
import 'package:triacore_mobile/widgets/triacore_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:no_screenshot/no_screenshot.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key});

  final _noScreenshot = NoScreenshot.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: TriacoreAppBar(title: "Configurações"),
      drawer: const TriacoreDrawer(),
      body: ListView(
        children: [
          _buildSettingsItem(
            context,
            "Ver frase de recuperação",
            Icons.vpn_key,
            () => _showRecoveryPhrase(context),
          ),
          _buildSettingsItem(
            context,
            "Mudar PIN",
            Icons.lock,
            () => _changePin(context),
          ),
          _buildSettingsItem(
            context,
            "Cupom de Indicação",
            Icons.card_giftcard,
            () => _showReferralInput(context),
          ),
          _buildSettingsItem(
            context,
            "Termos de uso",
            Icons.description,
            () => Navigator.pushNamed(context, "/terms-and-conditions"),
          ),
          _buildSettingsItem(
            context,
            "Política de Privacidade",
            Icons.privacy_tip,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
            ),
          ),
          _buildSettingsItem(
            context,
            "Contatar suporte",
            Icons.support_agent,
            () => _contactSupport(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    Function() onTap,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      color: Colors.black,
      elevation: 0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: "roboto",
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showRecoveryPhrase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VerifyPinScreen(
              onPinConfirmed: () async {
                final mnemonicHandler = MnemonicHandler();
                final mnemonic = await mnemonicHandler.retrieveWalletMnemonic(
                  "mainWallet",
                );
                await _noScreenshot.screenshotOff();

                if (mnemonic != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ViewMnemonicScreen(mnemonic: mnemonic),
                    ),
                  );
                }
              },
              forceAuth: true,
            ),
      ),
    );
  }

  void _changePin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VerifyPinScreen(
              onPinConfirmed: () {
                // After verifying current PIN, redirect to the PIN creation screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePinScreen()),
                );
              },
              forceAuth: true,
            ),
      ),
    );
  }

  void _showReferralInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferralInputScreen()),
    );
  }

  void _contactSupport(BuildContext context) async {
    final Uri url = Uri.parse("https://t.me/@triabr");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível abrir o Telegram")),
        );
      }
    }
  }
}
