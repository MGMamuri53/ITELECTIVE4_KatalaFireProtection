import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  static const double maxContentWidth = 1320;
  static const double cardBreakpoint = 920;
  static const double tableMinWidth = 920;

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

    String selectedCategory =
        (isEditing && _productCategories.contains(product['v_productCategory']))
        ? product['v_productCategory']
        : _productCategories.first;

    String selectedStatus = isEditing ? _statusFor(product) : 'IN STOCK';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
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
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _productCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Stock Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['IN STOCK', 'LOW STOCK', 'OUT OF STOCK'].map((
                    status,
                  ) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedStatus = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || skuController.text.isEmpty) {
                  return;
                }

                // KINUHA NA NATIN YUNG PRICE AT GINAWANG NUMBER
                final double parsedPrice =
                    double.tryParse(priceController.text) ?? 0.0;

                final data = {
                  'sku': skuController.text,
                  'name': nameController.text,
                  'price': parsedPrice, // ISINAMA NA ANG PRICE SA DATABASE
                  'category': selectedCategory,
                  'stock_status': selectedStatus,
                };

                try {
                  if (isEditing) {
                    await ApiClient.put(
                      '/admin/products/${product['v_productId']}',
                      data,
                    );
                  } else {
                    await ApiClient.post('/admin/products', data);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchProducts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Product Updated!' : 'Product Added!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String id) async {
    try {
      await ApiClient.delete('/admin/products/$id');
      _fetchProducts();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Product Management',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Manage technical equipment catalog, pricing, and stock levels.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showProductDialog(),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
                            SizedBox(height: isDesktop ? 24 : 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _filterProducts,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: const InputDecoration(
                                    hintText: 'Search SKU, Product Name...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, content) =>
                            content.maxWidth < cardBreakpoint
                            ? _buildProductCards()
                            : _buildProductTable(content),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductTable(BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth < tableMinWidth
            ? tableMinWidth
            : constraints.maxWidth,
        height: constraints.maxHeight,
        child: Column(
          children: [
            // TABLE HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 2),
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
                    flex: 2,
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
                    flex: 2,
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
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : _hasError
                  ? _buildErrorState()
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
                              product['v_currentPrice']?.toString() ?? '0',
                            ) ??
                            0.0;
                        final Color statusColor = _statusColorFor(status);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.surfaceMuted),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  product['v_productCode'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                              // BAGONG COLUMN PARA SA PRICE
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₱ ${price.toStringAsFixed(2)}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _actionButton(
                                      icon: Icons.edit_outlined,
                                      color: Colors.blue,
                                      tooltip: 'Edit product',
                                      onPressed: () =>
                                          _showProductDialog(product: product),
                                    ),
                                    _actionButton(
                                      icon: Icons.delete_outline,
                                      color: Colors.red,
                                      tooltip: 'Delete product',
                                      onPressed: () => _deleteProduct(
                                        product['v_productId'].toString(),
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
    );
  }

  Widget _buildProductCards() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }
    if (_hasError) return _buildErrorState();
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products match your search.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final status = _statusFor(product);
        final double price =
            double.tryParse(product['v_currentPrice']?.toString() ?? '0') ??
            0.0;
        final Color statusColor = _statusColorFor(status);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product['v_productName'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _actionButton(
                    icon: Icons.edit_outlined,
                    color: Colors.blue,
                    tooltip: 'Edit product',
                    onPressed: () => _showProductDialog(product: product),
                  ),
                  _actionButton(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    tooltip: 'Delete product',
                    onPressed: () =>
                        _deleteProduct(product['v_productId'].toString()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMetaChip(
                    Icons.qr_code_2,
                    product['v_productCode']?.toString() ?? '',
                  ),
                  _buildMetaChip(
                    Icons.category_outlined,
                    product['v_productCategory']?.toString() ?? '',
                  ),
                  _buildMetaChip(
                    Icons.payments_outlined,
                    '₱ ${price.toStringAsFixed(2)}',
                  ),
                  _buildStatusChip(status, statusColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Unable to load products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProducts,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 18),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      onPressed: onPressed,
    );
  }

  Widget _buildMetaChip(IconData icon, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
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

  Color _statusColorFor(String status) {
    if (status == 'LOW STOCK') return Colors.orange;
    if (status == 'OUT OF STOCK') return Colors.red;
    return Colors.green;
  }
}
