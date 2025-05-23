import 'package:flutter/material.dart';
import 'package:triacore_mobile/screens/store_mode/models/checkout_item.dart';
import 'package:triacore_mobile/screens/store_mode/models/store_item.dart';

class ProductServiceSelector extends StatelessWidget {
  final List<StoreItem> items;
  final Function(StoreItem) onItemSelected;
  final Function(StoreItem)? onRemoveItem;
  final bool showProducts;
  final Function(bool) onToggleView;
  final bool showRemoveButton;

  const ProductServiceSelector({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.onRemoveItem,
    required this.showProducts,
    required this.onToggleView,
    this.showRemoveButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) => item.isProduct == showProducts).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToggleButtons(
          isSelected: [showProducts, !showProducts],
          onPressed: (index) {
            onToggleView(index == 0);
          },
          borderRadius: BorderRadius.circular(8.0),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Produtos'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Serviços'),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (filteredItems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nenhum item disponível nesta categoria',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: item.description != null ? Text(item.description!) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'R\$ ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (showRemoveButton && onRemoveItem != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemoveItem!(item),
                        ),
                    ],
                  ),
                  onTap: () => onItemSelected(item),
                ),
              );
            },
          ),
      ],
    );
  }
}
