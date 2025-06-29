import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/network.dart';
import 'package:triacore_mobile/repositories/mempool.dart';

final mempoolRepositoryProvider = Provider.autoDispose
    .family<MempoolRepository, Network>((ref, network) {
      switch (network) {
        case Network.bitcoin:
          return BitcoinMempoolRepository();
        case Network.liquid:
          return LiquidMempoolRepository();
      }
    });
