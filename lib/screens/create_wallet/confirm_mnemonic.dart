import 'dart:math';
import 'package:flutter/material.dart';
import 'package:triacore_mobile/screens/pin/create_pin.dart';
import 'package:triacore_mobile/widgets/appbar.dart';
import 'package:triacore_mobile/widgets/buttons.dart';

class ConfirmMnemonicScreen extends StatefulWidget {
  final String mnemonic;

  const ConfirmMnemonicScreen({required this.mnemonic, super.key});

  @override
  ConfirmMnemonicScreenState createState() => ConfirmMnemonicScreenState();
}

class ConfirmMnemonicScreenState extends State<ConfirmMnemonicScreen> {
  late List<int> positions;
  late List<String> words;
  final Random random = Random();
  late TextEditingController controller1;
  late TextEditingController controller2;
  late TextEditingController controller3;

  @override
  void initState() {
    super.initState();
    words = widget.mnemonic.split(" ");
    positions = [];

    while (positions.length < 3) {
      int pos = random.nextInt(words.length) + 1;
      if (!positions.contains(pos)) {
        positions.add(pos);
      }
    }

    positions.sort();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TriacoreAppBar(title: "Confirmar frase de recuperação"),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align content
              children: [
                const Text(
                  "Por favor escreva as palavras a seguir de sua frase de recuperação para confirmar: ",
                  style: TextStyle(fontSize: 16, fontFamily: "roboto"),
                  textAlign: TextAlign.center, // Center text
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      buildWordInput(context, positions[0], controller1),
                      const SizedBox(height: 20),
                      buildWordInput(context, positions[1], controller2),
                      const SizedBox(height: 20),
                      buildWordInput(context, positions[2], controller3),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  PrimaryButton(
                    text: "Confirmar",
                    onPressed: () {
                      if (checkInputs()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePinScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Uma ou mais palavras estão incorretas. Tente novamente.",
                            ),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Also modify the buildWordInput method to ensure it handles width properly:
  Widget buildWordInput(
    BuildContext context,
    int position,
    TextEditingController controller,
  ) {
    InputDecorationTheme currentTextFieldTheme =
        Theme.of(context).inputDecorationTheme;

    return Container(
      width: double.infinity, // Make the container take full width
      child: Row(
        children: [
          Text(
            "Palavra #${position}: ",
            style: const TextStyle(fontFamily: "roboto"),
          ),
          SizedBox(
            width: (position >= 10) ? 8 : 14,
          ), // change padding due to digit width offset
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: currentTextFieldTheme.border,
                fillColor: currentTextFieldTheme.fillColor,
                filled: currentTextFieldTheme.filled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool checkInputs() {
    final input1 = controller1.text.trim().toLowerCase();
    final input2 = controller2.text.trim().toLowerCase();
    final input3 = controller3.text.trim().toLowerCase();
    final word1 = words[positions[0] - 1].toLowerCase();
    final word2 = words[positions[1] - 1].toLowerCase();
    final word3 = words[positions[2] - 1].toLowerCase();
    return input1 == word1 && input2 == word2 && input3 == word3;
  }
}
