import 'dart:math';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/assets.dart';
import 'package:triacore_mobile/providers/fiat/fiat_provider.dart';

class CoinBalance extends ConsumerWidget {
  OwnedAsset ownedAsset;
  double? fiatPrice;
  bool isBalanceVisible; // toggle to show/hide amount

  CoinBalance({
    super.key,
    required this.ownedAsset,
    this.isBalanceVisible = true,
  });

  void getAssetFiatPrice(AsyncValue<Map<String, double>> fiatPrices) {
    if (ownedAsset.asset.fiatPriceId == null) {
      return;
    }

    return fiatPrices.when(
      loading: () => {},
      error: (err, stack) {
        if (kDebugMode) {
          print("[ERROR] Could not load asset prices.");
        }
        return;
      },
      data: (prices) {
        if (!prices.containsKey(ownedAsset.asset.fiatPriceId!)) {
          return;
        }

        fiatPrice = prices[ownedAsset.asset.fiatPriceId];
        return;
      },
    );
  }

  String _formatBalance() {
    if (!isBalanceVisible) return "••••";
    if (ownedAsset.asset.precision == 0) return "${ownedAsset.amount}".trim();

    final double value =
        ownedAsset.amount / (pow(10, ownedAsset.asset.precision));
    return "${value.toStringAsFixed(ownedAsset.asset.precision)}".trim();
  }

  String _formatFiatValue() {
    if (fiatPrice == null) return "";
    if (!isBalanceVisible) return "••••";

    final double value =
        (ownedAsset.amount / pow(10, ownedAsset.asset.precision)) * fiatPrice!;
    return "R\$ ${value.toStringAsFixed(2)}"; // Format as BRL with 2 decimals
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiatPrices = ref.watch(fiatPricesProvider);
    getAssetFiatPrice(fiatPrices);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(ownedAsset.asset.logoPath),
          ),
          const SizedBox.square(dimension: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownedAsset.asset.name,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatBalance(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "roboto",
                      ),
                    ),
                    Text(
                      _formatFiatValue(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: "roboto",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
