import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:triacore_mobile/screens/store_mode/models/store_item.dart';

class StoreItemFormDialog extends StatefulWidget {
  final StoreItem? initialItem;

  const StoreItemFormDialog({
    Key? key,
    this.initialItem,
  }) : super(key: key);

  @override
  State<StoreItemFormDialog> createState() => _StoreItemFormDialogState();
}

class _StoreItemFormDialogState extends State<StoreItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late bool _isProduct;
  late String? _imageUrl;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _name = widget.initialItem?.name ?? '';
    _description = widget.initialItem?.description ?? '';
    _price = widget.initialItem?.price ?? 0.0;
    _isProduct = widget.initialItem?.isProduct ?? true;
    _imageUrl = widget.initialItem?.imageUrl;
    if (_imageUrl != null &&
        _imageUrl!.isNotEmpty &&
        File(_imageUrl!).existsSync()) {
      _pickedImage = File(_imageUrl!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          pickedFile.name;
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _pickedImage = savedImage;
        _imageUrl = savedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Adicionar Item' : 'Editar Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price > 0 ? _price.toStringAsFixed(2) : '',
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um preço';
                  }
                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null || price <= 0) {
                    return 'Por favor, insira um preço válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!.replaceAll(',', '.'));
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tipo:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isProduct,
                          onChanged: (value) {
                            setState(() {
                              _isProduct = value!;
                            });
                          },
                        ),
                        const Flexible(
                            child: Text('Produto',
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: _isProduct,
                          onChanged: (value) {
                            setState(() {
                              _isProduct = !value!;
                            });
                          },
                        ),
                        const Flexible(
                            child: Text('Serviço',
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ],
              ),
              // Campo de imagem
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage == null
                      ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final item = StoreItem(
        id: widget.initialItem?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        description: _description.isEmpty ? null : _description,
        price: _price,
        isProduct: _isProduct,
        imageUrl: _imageUrl,
      );

      Navigator.of(context).pop(item);
    }
  }
}
