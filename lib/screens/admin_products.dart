import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _productCategories = [
    'Extinguishers',
    'Fire Alarms & Panels',
    'Sprinkler Systems',
    'Pumps & Piping',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    _hasError = false;
    try {
      final response = await ApiClient.get('/products');
      if (mounted) {
        setState(() {
          _allProducts = List<Map<String, dynamic>>.from(response);
          _filteredProducts = _allProducts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load products. Please check your internet connection.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterProducts(String query) {
    if (_hasError) return; // Don't filter if there's an error

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final name = (product['v_productName'] ?? '')
              .toString()
              .toLowerCase();
          final sku = (product['v_productCode'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || sku.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final isEditing = product != null;
    final skuController = TextEditingController(
      text: isEditing ? product['v_productCode'] : '',
    );
    final nameController = TextEditingController(
      text: isEditing ? product['v_productName'] : '',
    );
    // BAGONG CONTROLLER PARA SA PRICE
    final priceController = TextEditingController(
      text: isEditing ? (product['v_currentPrice']?.toString() ?? '0') : '',
    );
    final quantityController = TextEditingController(
      text: isEditing ? (product['v_quantityOnHand']?.toString() ?? '0') : '0',
    );

    String selectedCategory =
        (isEditing && _productCategories.contains(product['v_productCategory']))
        ? product['v_productCategory']
        : _productCategories.first;
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isSaving = false;
    final imagePicker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              isEditing ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU (e.g. EXT-01)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // BAGONG TEXTFIELD PARA SA PRICE
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price (₱)',
                      border: OutlineInputBorder(),
                      prefixText: '₱ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _productCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedCategory = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity on hand',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final image = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                        maxWidth: 1600,
                      );
                      if (image == null) return;
                      final bytes = await image.readAsBytes();
                      setDialogState(() {
                        selectedImageBytes = bytes;
                        selectedImageName = image.name;
                      });
                    },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(selectedImageName ?? 'Choose product picture'),
                  ),
                  if (selectedImageBytes != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        selectedImageBytes!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (nameController.text.isEmpty ||
                            skuController.text.isEmpty) {
                          return;
                        }

                        // KINUHA NA NATIN YUNG PRICE AT GINAWANG NUMBER
                        final double parsedPrice =
                            double.tryParse(priceController.text) ?? 0.0;
                        final quantityOnHand = double.tryParse(
                          quantityController.text,
                        );
                        if (quantityOnHand == null || quantityOnHand < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enter a valid non-negative stock quantity.',
                              ),
                            ),
                          );
                          return;
                        }

                        final data = {
                          'sku': skuController.text.trim(),
                          'name': nameController.text.trim(),
                          'price':
                              parsedPrice, // ISINAMA NA ANG PRICE SA DATABASE
                          'category': selectedCategory,
                          'quantity_on_hand': quantityOnHand,
                        };

                        var wasProductSaved = false;
                        try {
                          setDialogState(() => isSaving = true);
                          String productId;
                          if (isEditing) {
                            productId = product['v_productId'].toString();
                            await ApiClient.put(
                              '/admin/products/$productId',
                              data,
                            );
                          } else {
                            final response = await ApiClient.post(
                              '/admin/products',
                              data,
                            );
                            productId = response['id'].toString();
                          }
                          wasProductSaved = true;
                          if (selectedImageBytes != null) {
                            await ApiClient.uploadImage(
                              '/admin/products/$productId/image',
                              selectedImageBytes!,
                              selectedImageName ?? 'product-image.jpg',
                            );
                          }
                          if (mounted) {
                            Navigator.pop(context);
                            _fetchProducts();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Product Updated!'
                                      : 'Product Added!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (wasProductSaved && mounted) {
                            Navigator.pop(context);
                            _fetchProducts();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Product saved, but its image upload failed: $e',
                                ),
                              ),
                            );
                          } else {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unable to save product: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                ),
                child: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update' : 'Save',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteProduct(String id) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Archive product?'),
          content: const Text(
            'The product will be hidden from active catalog listings. Its order history will be retained.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ApiClient.delete('/admin/products/$id');
      await _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product archived.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to archive product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Product Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage technical equipment catalog, pricing, and stock levels.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Add Product',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: const InputDecoration(
                      hintText: 'Search SKU, Product Name...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 850, // INI-ADJUST NATIN ANG WIDTH PARA KASYA ANG PRICE
                child: Column(
                  children: [
                    // TABLE HEADER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'SKU',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex:
                                2, // BINAGONG FLEX PARA KASYA ANG PRICE SA TABI
                            child: Text(
                              'PRODUCT NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // BAGONG HEADER PARA SA PRICE
                          Expanded(
                            flex: 1,
                            child: Text(
                              'PRICE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'STATUS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TABLE CONTENT
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brand,
                              ),
                            )
                          : _hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Unable to load products',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please check your internet connection',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchProducts,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brand,
                                    ),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'No products match your search.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                final status = _statusFor(product);
                                // KUNIN ANG PRICE PARA IDISPLAY
                                final double price =
                                    double.tryParse(
                                      product['v_currentPrice']?.toString() ??
                                          '0',
                                    ) ??
                                    0.0;

                                Color statusColor = Colors.green;
                                if (status == 'LOW STOCK') {
                                  statusColor = Colors.orange;
                                }
                                if (status == 'OUT OF STOCK') {
                                  statusColor = Colors.red;
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.surfaceMuted,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          product['v_productCode'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          product['v_productName'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          product['v_productCategory'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                      // BAGONG COLUMN PARA SA PRICE
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '₱ ${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.brand,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blue,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _showProductDialog(
                                                    product: product,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              onPressed: () => _deleteProduct(
                                                product['v_productId']
                                                    .toString(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusFor(Map<String, dynamic> product) {
    final quantity =
        double.tryParse(product['v_quantityAvailable']?.toString() ?? '0') ?? 0;

    if (quantity <= 0) return 'OUT OF STOCK';
    if (quantity <= 5) return 'LOW STOCK';
    return 'IN STOCK';
  }
}
