import 'package:triacore_mobile/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:triacore_mobile/services/auth.dart';
import 'package:triacore_mobile/widgets/appbar.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String pin;
  ConfirmPinScreen({required this.pin});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

// Screen to confirm the PIN entered by the user at create_pin.dart
// For other verifications, use verify_pin with a callback function
class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  final TextEditingController pinController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  Future<void> savePin() async {
    await _authService.createPin(widget.pin);
    Navigator.pushReplacementNamed(context, '/splash');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TriacoreAppBar(title: "Confirmar PIN"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Limit max width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center children
              children: [
                Spacer(),
                Text(
                  "Confirme seu PIN:",
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
                  validator: (pin) {
                    if (pin == widget.pin) {
                      return null;
                    } else {
                      return "PINs não coincidem";
                    }
                  },
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
                  onPressed: () async {
                    if (pinController.text != widget.pin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("PINs não coincidem")),
                      );
                    } else {
                      await savePin();
                    }
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
