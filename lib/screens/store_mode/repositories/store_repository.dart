import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:triacore_mobile/screens/store_mode/models/checkout_item.dart';
import 'package:triacore_mobile/screens/store_mode/models/store_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreRepository {
  static const String _storeItemsKey = 'store_items';
  List<StoreItem> _storeItems = [];
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _loadStoreItems();
      _isInitialized = true;
    }
  }

  Future<void> _loadStoreItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getStringList(_storeItemsKey) ?? [];
    
    if (itemsJson.isEmpty) {
      // Itens iniciais padrão
      _storeItems = [
        StoreItem(
          id: '1',
          name: 'Produto 1',
          price: 49.90,
          description: 'Descrição do Produto 1',
        ),
        StoreItem(
          id: '2',
          name: 'Produto 2',
          price: 99.90,
          description: 'Descrição do Produto 2',
        ),
        StoreItem(
          id: '3',
          name: 'Serviço 1',
          price: 149.90,
          description: 'Descrição do Serviço 1',
          isProduct: false,
        ),
      ];
      await _saveStoreItems();
    } else {
      try {
        _storeItems = itemsJson
            .map((item) {
              // Primeiro, convertemos a string JSON para um Map
              final itemMap = Map<String, dynamic>.from(jsonDecode(item));
              // Depois, usamos o fromMap para criar o objeto StoreItem
              return StoreItem.fromMap(itemMap);
            })
            .toList();
      } catch (e) {
        // Se houver algum erro ao fazer o parse, limpa os itens inválidos
        debugPrint('Erro ao carregar itens: $e');
        _storeItems = [];
      }
    }
  }

  Future<void> _saveStoreItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Converte cada item para um Map e depois para uma string JSON
      final itemsJson = _storeItems
          .map((item) => jsonEncode(item.toMap()))
          .toList();
      await prefs.setStringList(_storeItemsKey, itemsJson);
    } catch (e) {
      debugPrint('Erro ao salvar itens: $e');
      rethrow;
    }
  }

  Future<List<StoreItem>> getStoreItems() async {
    await _ensureInitialized();
    
    if (_storeItems.isEmpty) {
      throw Exception('Nenhum item cadastrado');
    }
    
    return List<StoreItem>.from(_storeItems);
  }

  Future<void> addStoreItem(StoreItem item) async {
    await _ensureInitialized();
    _storeItems.add(item);
    await _saveStoreItems();
  }

  Future<void> updateStoreItem(StoreItem updatedItem) async {
    await _ensureInitialized();
    final index = _storeItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _storeItems[index] = updatedItem;
      await _saveStoreItems();
    }
  }

  Future<void> removeStoreItem(String id) async {
    try {
      await _ensureInitialized();
      final initialCount = _storeItems.length;
      _storeItems.removeWhere((item) => item.id == id);
      
      if (initialCount == _storeItems.length) {
        throw Exception('Item não encontrado');
      }
      
      await _saveStoreItems();
    } catch (e) {
      debugPrint('Erro ao remover item: $e');
      rethrow;
    }
  }
}
