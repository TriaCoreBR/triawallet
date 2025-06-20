import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/asset_catalog.dart';
import 'package:triacore_mobile/providers/fiat/fiat_provider.dart';
import 'package:triacore_mobile/utils/fees.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionInfo extends ConsumerWidget {
  final String assetId;
  final String address;
  final int amount; // Amount in cents

  TransactionInfo({
    super.key,
    required this.assetId,
    required this.address,
    required this.amount,
  });

  Widget _buildTransactionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 16,
              color: Colors.white, // Rótulo em branco
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: "roboto", 
              fontSize: 16,
              color: Colors.green, // Valor em verde
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<bool> _hasReferral() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('referralCode') != null;
  }

  Future<Map<String, double>> calculateAmounts(
    String assetId,
    int amount,
    double fiatPrice,
    bool hasReferral,
  ) async {
    final feeCalculator = FeeCalculator(
      assetId: assetId,
      fiatAmount: amount,
      hasReferral: hasReferral,
    );
    final feeRate = feeCalculator.getFees();

    final amountInReais = (amount - 100) / 100.0;
    final assetAmount = amountInReais / fiatPrice;
    final fees = assetAmount * feeRate;
    final amountToReceive = assetAmount - fees;

    return {
      'amountToReceive': amountToReceive,
      'fees': fees,
      'feeRate': feeRate,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiatPrices = ref.watch(fiatPricesProvider);
    final assetInfo = AssetCatalog.getByLiquidAssetId(assetId);

    return fiatPrices.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text("Erro ao gerar pagamento, tente novamente."),
      data: (data) {
        final fiatPrice = data[assetInfo!.fiatPriceId];
        if (fiatPrice == null) {
          return Text("Erro ao obter cotação do ativo.");
        }

        return FutureBuilder<bool>(
          future: _hasReferral(),
          builder: (context, referralSnapshot) {
            if (referralSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final hasReferral = referralSnapshot.data ?? false;

            return FutureBuilder<Map<String, double>>(
              future: calculateAmounts(assetId, amount, fiatPrice, hasReferral),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Erro ao calcular taxas: ${snapshot.error}");
                }

                final amounts = snapshot.data!;
                final amountToReceive = amounts['amountToReceive']!;
                final fees = amounts['fees']!;
                final feeRate = amounts['feeRate']!;

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _buildTransactionDetailRow(
                        "Valor",
                        "R\$ ${(amount / 100).toStringAsFixed(2)}",
                      ),
                      _buildTransactionDetailRow("Cotação", "$fiatPrice"),
                      _buildTransactionDetailRow(
                        "Quantidade",
                        "${amountToReceive.toStringAsFixed(assetInfo.precision)} ${assetInfo.ticker}",
                      ),
                      _buildTransactionDetailRow(
                        "Taxa",
                        "${fees.toStringAsFixed(assetInfo.precision)} ${assetInfo.ticker} (${(feeRate * 100).toStringAsFixed(2)}%)",
                      ),
                      _buildTransactionDetailRow(
                        "Endereço",
                        "${address.substring(0, 5)}...${address.substring(address.length - 5)}",
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
