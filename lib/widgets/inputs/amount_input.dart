import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/assets.dart';
import 'package:triacore_mobile/providers/fiat/fiat_provider.dart';
import 'package:triacore_mobile/widgets/inputs/convertible_amount_input.dart';

class AmountInput extends ConsumerWidget {
  final Asset asset;
  final TextEditingController controller;
  final Function(double amount) onAmountChanged;
  final int? fees;
  final int? maxAmount;

  AmountInput({
    required this.asset,
    required this.controller,
    required this.onAmountChanged,
    this.fees,
    this.maxAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiatPrices = ref.watch(fiatPricesProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    final fiatPrice = fiatPrices.when(
      loading: () => 0.0,
      error: (err, stack) => 0.0,
      data: (data) => data[asset.fiatPriceId] ?? 0.0,
    );

    return ConvertibleAmountInput(
      assetId: asset.id,
      assetTicker: asset.ticker,
      assetPrecision: asset.precision,
      fiatCurrency: baseCurrency,
      fiatPrice: fiatPrice,
      controller: controller,
      onAmountChanged: onAmountChanged,
      fees: fees,
      maxAmount: maxAmount,
    );
  }
}
