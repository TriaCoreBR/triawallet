import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:triacore_mobile/models/asset_catalog.dart';
import 'package:triacore_mobile/providers/external/coingecko_price_provider.dart';

part 'fiat_provider.g.dart';

@Riverpod()
String baseCurrency(Ref ref) {
  return "BRL";
}

@Riverpod()
Future<Map<String, double>> fiatPrices(Ref ref) async {
  final baseCurrency = ref.watch(baseCurrencyProvider);
  final assets = AssetCatalog.all;

  final coingeckoAssets =
      assets
          .where((asset) => asset.fiatPriceId != null)
          .map((asset) => asset.fiatPriceId!)
          .toList();

  final CoingeckoAssetPairs coingeckoAssetPairs = CoingeckoAssetPairs(
    assets: coingeckoAssets,
    baseCurrency: baseCurrency,
  );

  // Use the cached provider that auto-refreshes
  final fiatPrices = await ref.read(
    coingeckoPriceProvider(coingeckoAssetPairs).future,
  );

  if (!fiatPrices.containsKey("tether")) {
    return fiatPrices;
  }

  final usdPrice = fiatPrices["tether"]!;
  final depixPrice = getDepixPrice(baseCurrency, usdPrice);

  // Create a new map to avoid modifying the original
  final result = Map<String, double>.from(fiatPrices);
  result["depix"] = depixPrice;

  return result;
}

double getDepixPrice(String baseCurrency, double usdPrice) {
  if (baseCurrency == "BRL") return 1.0;
  return 1.0 / usdPrice;
}
