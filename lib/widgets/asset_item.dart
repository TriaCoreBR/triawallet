import 'package:flutter/material.dart';

class AssetItem extends StatelessWidget {
  final String assetName;
  final String assetIconPath;
  final String balance;
  final bool isBalanceVisible;

  const AssetItem({
    Key? key,
    required this.assetName,
    required this.assetIconPath,
    required this.balance,
    required this.isBalanceVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayBalance = isBalanceVisible ? balance : "••••";

    return Container(
      width: double.infinity, // Fill parent width
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Image.asset(assetIconPath, width: 40, height: 40),
        title: Text(
          assetName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          "Saldo: $displayBalance",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
