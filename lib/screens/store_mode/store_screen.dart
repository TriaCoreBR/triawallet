import 'package:flutter/material.dart';
import 'package:triacore_mobile/screens/receive_pix/receive_pix.dart';
import 'package:triacore_mobile/screens/store_mode/models/checkout_item.dart';
import 'package:triacore_mobile/screens/store_mode/models/store_item.dart';
import 'package:triacore_mobile/screens/store_mode/repositories/store_repository.dart';
import 'package:triacore_mobile/screens/store_mode/screens/manage_store_items_screen.dart';
import 'package:triacore_mobile/screens/store_mode/widgets/store/checkout_item_card.dart';
import 'package:triacore_mobile/screens/store_mode/widgets/store/checkout_summary.dart';
import 'package:triacore_mobile/screens/store_mode/widgets/store/product_service_selector.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Para debug
void debugPrint(String message) {
  assert(() {
    print(message);
    return true;
  }());
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<CheckoutItem> _cartItems = [];
  bool _isLoading = false;
  bool _showProducts = true;
  
  final StoreRepository _storeRepository = StoreRepository();
  List<StoreItem> _storeItems = [];
  
  // Índice da aba atual (0 = Produtos, 1 = Serviços)
  int _currentTabIndex = 0;

  File? _pickedImage;

  Future<void> _pickImage(Function(String?) onImageSelected) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + pickedFile.name;
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _pickedImage = savedImage;
      });
      onImageSelected(savedImage.path);
    } else {
      onImageSelected(null);
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('StoreScreen: initState chamado');
    _loadStoreItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('StoreScreen: didChangeDependencies chamado');
  }

  Future<void> _loadStoreItems() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final items = await _storeRepository.getStoreItems();
      if (!mounted) return;
      
      setState(() => _storeItems = items);
    } catch (e) {
      debugPrint('Erro ao carregar itens da loja: $e');
      
      if (!mounted) return;
      
      // Trata o caso de lista vazia
      if (e.toString().contains('Nenhum item cadastrado') || 
          e.toString().contains('Item não encontrado')) {
        setState(() => _storeItems = []);
      } else {
        // Mostra mensagem de erro apenas se for um erro inesperado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar itens da loja')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Constrói a lista de produtos ou serviços
  Widget _buildProductList(bool showProducts) {
    final filteredItems = _storeItems.where((item) => item.isProduct == showProducts).toList();
    
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showProducts ? Icons.shopping_bag_outlined : Icons.miscellaneous_services_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              showProducts 
                ? 'Nenhum produto cadastrado' 
                : 'Nenhum serviço cadastrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showProducts
                  ? 'Toque no botão + para adicionar produtos'
                  : 'Toque no botão + para adicionar serviços',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () => _addItem(item),
            borderRadius: BorderRadius.circular(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagem do produto/serviço
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty && File(item.imageUrl!).existsSync()
                          ? DecorationImage(
                              image: FileImage(File(item.imageUrl!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (item.imageUrl == null || item.imageUrl!.isEmpty || !File(item.imageUrl!).existsSync())
                        ? Center(
                            child: Icon(
                              item.isProduct 
                                  ? Icons.shopping_bag_outlined 
                                  : Icons.miscellaneous_services_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          )
                        : null,
                  ),
                ),
                // Detalhes do produto/serviço
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.description != null && item.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Spacer(),
                        Text(
                          'R\$ ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Adiciona um item ao carrinho
  void _addItem(StoreItem storeItem) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere((i) => i.id == storeItem.id);
      if (existingItemIndex >= 0) {
        // Se o item já existe no carrinho, incrementa a quantidade
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
        );
      } else {
        // Se é um novo item, adiciona ao carrinho
        _cartItems.add(CheckoutItem(
          id: storeItem.id,
          name: storeItem.name,
          price: storeItem.price,
          description: storeItem.description,
          isProduct: storeItem.isProduct,
          quantity: 1,
        ));
      }
      
      // Mostra um feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${storeItem.name} adicionado ao carrinho'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // Remove um item do carrinho
  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  // Atualiza a quantidade de um item no carrinho
  void _updateQuantity(String id, int quantity) {
    if (quantity < 1) {
      _removeItem(id);
      return;
    }
    
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      }
    });
  }

  // Processa o pagamento navegando para a tela de PIX
  void _processPayment() {
    // Verificar se há itens no carrinho
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens ao carrinho')),
      );
      return;
    }

    // Calcular o total da compra
    final total = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    
    // Navegar para a tela de pagamento PIX com o valor total
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceivePixScreen.withAmount(
          initialAmount: total,
        ),
      ),
    ).then((_) {
      // Limpar o carrinho após o pagamento ser concluído
      if (mounted) {
        setState(() {
          _cartItems.clear();
        });
      }
    });
  }

  void _showAddProductDialog() {
    // Garantindo que o foco seja removido ao abrir o diálogo
    FocusScope.of(context).unfocus();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isProduct = true;
    bool _isDisposed = false;
    File? localImage;

    void _disposeControllers() {
      if (!_isDisposed) {
        nameController.dispose();
        priceController.dispose();
        descriptionController.dispose();
        _isDisposed = true;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _disposeControllers();
            return true;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Adicionar Produto/Serviço'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage((path) {
                            setState(() {
                              if (path != null) {
                                localImage = File(path);
                              }
                            });
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: localImage != null
                                ? DecorationImage(
                                    image: FileImage(localImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: localImage == null
                              ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Preço',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descrição (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Tipo:'),
                          SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Produto'),
                            selected: isProduct,
                            onSelected: (selected) {
                              setState(() {
                                isProduct = true;
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Serviço'),
                            selected: !isProduct,
                            onSelected: (selected) {
                              setState(() {
                                isProduct = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _disposeControllers();
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final price = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                      if (name.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preencha o nome e o preço corretamente')),
                        );
                        return;
                      }
                      final newItem = StoreItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        price: price,
                        description: descriptionController.text.trim().isNotEmpty 
                            ? descriptionController.text.trim() 
                            : null,
                        isProduct: isProduct,
                        imageUrl: localImage?.path, // Salva o path local
                      );
                      _storeRepository.addStoreItem(newItem).then((_) {
                        _loadStoreItems();
                        Navigator.pop(context);
                        _disposeControllers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${isProduct ? 'Produto' : 'Serviço'} adicionado com sucesso!'),
                            action: SnackBarAction(
                              label: 'Ver Carrinho',
                              onPressed: _showCartDialog,
                            ),
                          ),
                        );
                      });
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((_) {
      _disposeControllers();
    });
  }

  // Mostra o diálogo do carrinho
  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Carrinho de Compras',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              if (_cartItems.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Seu carrinho está vazio'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return CheckoutItemCard(
                        item: item,
                        onRemove: () => _removeItem(item.id),
                        onQuantityChanged: (quantity) => 
                            _updateQuantity(item.id, quantity),
                      );
                    },
                  ),
                ),
              if (_cartItems.isNotEmpty)
                CheckoutSummary(
                  items: _cartItems,
                  onCheckout: _processPayment,
                  isLoading: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o ícone do carrinho com contador
  Widget _buildCartIcon() {
    final itemCount = _cartItems.fold(0, (sum, item) => sum + item.quantity);
    
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: _showCartDialog,
        ),
        if (itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Loja'),
        actions: [
          _buildCartIcon(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storeItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhum item cadastrado',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageStoreItemsScreen(),
                            ),
                          ).then((_) => _loadStoreItems());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Itens'),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(icon: Icon(Icons.shopping_bag), text: 'Produtos'),
                          Tab(icon: Icon(Icons.miscellaneous_services), text: 'Serviços'),
                        ],
                        onTap: (index) {
                          setState(() {
                            _currentTabIndex = index;
                            _showProducts = index == 0;
                          });
                        },
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Aba de Produtos
                            _buildProductList(true),
                            // Aba de Serviços
                            _buildProductList(false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStoreItemsScreen(),
            ),
          ).then((_) => _loadStoreItems());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Método para remover um item da loja
  Future<void> _removeStoreItem(StoreItem item) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja remover o item "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    try {
      await _storeRepository.removeStoreItem(item.id);
      if (!mounted) return;
      
      setState(() {
        _storeItems.removeWhere((i) => i.id == item.id);
      });
      
      // Mostra mensagem de sucesso apenas se ainda estiver montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso')),
        );
      }
    } catch (e) {
      // Não mostra mensagem de erro se o item não for encontrado (pode já ter sido removido)
      if (e.toString().contains('Item não encontrado')) {
        // Atualiza a lista para refletir o estado atual
        if (mounted) {
          setState(() {
            _storeItems = _storeItems.where((i) => i.id != item.id).toList();
          });
        }
        return;
      }
      
      // Mostra mensagem de erro apenas para outros erros inesperados
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover o item')),
        );
      }
      debugPrint('Erro ao remover item: $e');
    }
  }
}
