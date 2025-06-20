import 'package:flutter/material.dart';
import 'package:triacore_mobile/models/assets.dart';
import 'package:triacore_mobile/models/asset_catalog.dart';

class MarketDropdown extends StatefulWidget {
  final Function(String sendAssetId, String recvAssetId) onMarketSelect;

  const MarketDropdown({super.key, required this.onMarketSelect});

  @override
  State<MarketDropdown> createState() => _MarketDropdownState();
}

class _MarketDropdownState extends State<MarketDropdown> {
  Asset? sendAsset;
  Asset? recvAsset;
  List<Asset> possiblePairs = depixPairs;

  static List<Asset> depixPairs = [
    AssetCatalog.getById("usdt")!,
    AssetCatalog.getById("lbtc")!,
  ];
  static List<Asset> usdtPairs = [
    AssetCatalog.getById("lbtc")!,
    AssetCatalog.getById("depix")!,
  ];
  static List<Asset> lbtcPairs = [
    AssetCatalog.getById("usdt")!,
    AssetCatalog.getById("depix")!,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onSendAssetChange(Asset? asset) {
    if (asset == null) return;

    setState(() {
      sendAsset = asset;
      if (asset.id == "depix") {
        possiblePairs = depixPairs;
        // Only change recvAsset if not previously set or not in valid pairs
        if (recvAsset == null || !depixPairs.contains(recvAsset)) {
          recvAsset = depixPairs[0];
        }
      } else if (asset.id == "lbtc") {
        possiblePairs = lbtcPairs;
        if (recvAsset == null || !lbtcPairs.contains(recvAsset)) {
          recvAsset = lbtcPairs[0];
        }
      } else if (asset.id == "usdt") {
        possiblePairs = usdtPairs;
        if (recvAsset == null || !usdtPairs.contains(recvAsset)) {
          recvAsset = usdtPairs[0];
        }
      }
    });

    // Always notify parent of the change
    if (sendAsset != null && recvAsset != null) {
      widget.onMarketSelect(
        sendAsset!.liquidAssetId!,
        recvAsset!.liquidAssetId!,
      );
    }
  }

  void onRecvAssetChange(Asset? asset) {
    if (asset == null) return;

    // Only update if actually changed
    if (recvAsset != asset) {
      setState(() {
        recvAsset = asset;
      });

      // Always notify parent of the change
      if (sendAsset != null && recvAsset != null) {
        widget.onMarketSelect(
          sendAsset!.liquidAssetId!,
          recvAsset!.liquidAssetId!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Enviar: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                DropdownMenu(
                  leadingIcon:
                      (sendAsset == null)
                          ? null
                          : Transform.scale(
                            scale: 0.5,
                            child: Image.asset(
                              sendAsset!.logoPath,
                              width: 8,
                              height: 8,
                            ),
                          ),
                  textAlign: TextAlign.center,
                  dropdownMenuEntries:
                      AssetCatalog.liquidAssets
                          .map(
                            (asset) => DropdownMenuEntry(
                              value: asset,
                              label: asset.ticker,
                              leadingIcon: Image.asset(
                                asset.logoPath,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          )
                          .toList(),
                  onSelected: (Asset? asset) => onSendAssetChange(asset),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Receber: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                DropdownMenu(
                  leadingIcon:
                      (recvAsset == null)
                          ? null
                          : Transform.scale(
                            scale: 0.5,
                            child: Image.asset(
                              recvAsset!.logoPath,
                              width: 8,
                              height: 8,
                            ),
                          ),
                  textAlign: TextAlign.center,
                  initialSelection: recvAsset,
                  dropdownMenuEntries:
                      possiblePairs
                          .map(
                            (asset) => DropdownMenuEntry(
                              value: asset,
                              label: asset.ticker,
                              leadingIcon: Image.asset(
                                asset.logoPath,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          )
                          .toList(),
                  onSelected: (Asset? asset) => onRecvAssetChange(asset),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
