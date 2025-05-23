import 'package:flutter/material.dart';
import 'package:triacore_mobile/screens/store_mode/models/store_item.dart';
import 'package:triacore_mobile/screens/store_mode/repositories/store_repository.dart';
import 'package:triacore_mobile/screens/store_mode/widgets/store/store_item_form_dialog.dart';

class ManageStoreItemsScreen extends StatefulWidget {
  const ManageStoreItemsScreen({Key? key}) : super(key: key);

  @override
  State<ManageStoreItemsScreen> createState() => _ManageStoreItemsScreenState();
}

class _ManageStoreItemsScreenState extends State<ManageStoreItemsScreen> {
  final StoreRepository _storeRepository = StoreRepository();
  late Future<List<StoreItem>> _storeItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadStoreItems();
  }

  void _loadStoreItems() {
    setState(() {
      _storeItemsFuture = _storeRepository.getStoreItems();
    });
  }

  Future<void> _addItem() async {
    final result = await showDialog<StoreItem?>(
      context: context,
      builder: (context) => const StoreItemFormDialog(),
    );

    if (result != null) {
      await _storeRepository.addStoreItem(result);
      _loadStoreItems();
    }
  }

  Future<void> _editItem(StoreItem item) async {
    final result = await showDialog<StoreItem?>(
      context: context,
      builder: (context) => StoreItemFormDialog(initialItem: item),
    );

    if (result != null) {
      await _storeRepository.updateStoreItem(result);
      _loadStoreItems();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja remover este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _storeRepository.removeStoreItem(id);
      _loadStoreItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Itens da Loja'),
      ),
      body: FutureBuilder<List<StoreItem>>(
        future: _storeItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar itens: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum item cadastrado.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Adicionar Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    'R\$ ${item.price.toStringAsFixed(2)} • ${item.isProduct ? 'Produto' : 'Serviço'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(item.id),
                      ),
                    ],
                  ),
                  onTap: () => _editItem(item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
