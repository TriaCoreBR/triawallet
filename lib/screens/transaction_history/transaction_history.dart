import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/transaction.dart';
import 'package:triacore_mobile/providers/multichain/transaction_history_provider.dart';
import 'package:triacore_mobile/screens/transaction_history/widgets/transaction_display.dart';
import 'package:triacore_mobile/widgets/appbar.dart';
import 'package:triacore_mobile/widgets/triacore_drawer.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionHistory = ref.watch(transactionHistoryProvider.future);

    return Scaffold(
      appBar: TriacoreAppBar(title: "Histórico de transações"),
      drawer: const TriacoreDrawer(),
      body: FutureBuilder<List<TransactionRecord>>(
        future: transactionHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder:
                (context, index) =>
                    TransactionDisplay(transaction: transactions[index]),
          );
        },
      ),
    );
  }
}
