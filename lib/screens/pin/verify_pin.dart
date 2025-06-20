import 'package:flutter/material.dart';
import 'package:triacore_mobile/utils/mnemonic.dart';
import 'package:triacore_mobile/utils/store_mode.dart';
import 'package:triacore_mobile/widgets/buttons.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:pinput/pinput.dart';
import 'package:triacore_mobile/services/auth.dart';
import 'package:triacore_mobile/widgets/appbar.dart';

/// Screen to verify PIN for sensitive operations.
class VerifyPinScreen extends StatefulWidget {
  final Function() onPinConfirmed;
  bool forceAuth;
  bool isAppResuming;

  VerifyPinScreen({
    super.key,
    required this.onPinConfirmed,
    this.forceAuth = false,
    this.isAppResuming = false,
  });
  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController pinController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final hasValidSession = await _authService.hasValidSession();
    final isPinSetup = await _authService.isPinSetup();
    final isStoreMode = await StoreModeHandler().isStoreMode();

    final noScreenshot = NoScreenshot.instance;
    await noScreenshot.screenshotOn();

    // Skip verification if:
    // 1. We're in store mode, or
    // 2. User authenticated less than a minute ago (and we're not forcing auth), or
    // 3. No PIN has been set up
    if ((isStoreMode && !widget.forceAuth) ||
        (hasValidSession && !widget.forceAuth) ||
        !isPinSetup) {
      setState(() {
        _isLocked = false;
      });
      widget.onPinConfirmed();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: TriacoreAppBar(title: "Validar PIN"),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Validar PIN",
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: !widget.isAppResuming,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                "Digite seu PIN:",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Pinput(
                keyboardType: TextInputType.number,
                length: 6,
                obscureText: true,
                controller: pinController,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontFamily: "roboto",
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Spacer(),
              PrimaryButton(
                text: "Continuar",
                onPressed:
                    _isVerifying
                        ? () {}
                        : () {
                          if (pinController.text.length < 6) return;

                          setState(() {
                            _isVerifying = true;
                          });

                          _authService
                              .authenticate(pinController.text)
                              .then((auth) {
                                if (auth && mounted) {
                                  print("Auth successful");
                                  setState(() {
                                    _isLocked = false;
                                  });
                                  widget.onPinConfirmed();
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'PIN incorreto. Tente novamente.',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  pinController.clear();
                                }
                              })
                              .catchError((error) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erro: ${error.toString()}',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  pinController.clear();
                                }
                              })
                              .whenComplete(() {
                                if (mounted) {
                                  setState(() {
                                    _isVerifying = false;
                                  });
                                }
                              });
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
