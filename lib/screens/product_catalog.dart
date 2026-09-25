import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class ProductCatalog extends StatefulWidget {
  const ProductCatalog({super.key});

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Extinguishers', 'icon': Icons.fire_extinguisher},
    {
      'name': 'Fire Alarms & Panels',
      'icon': Icons.notifications_active_outlined,
    },
    {'name': 'Sprinkler Systems', 'icon': Icons.shower_outlined},
    {'name': 'Pumps & Piping', 'icon': Icons.water_damage_outlined},
  ];

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/products'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load products: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  // 1. PRODUCT DETAILS WITH QUANTITY AND FULFILLMENT SELECTION
  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    int quantity = 1;
    String fulfillmentMethod = 'Delivery';

    // Parse price safely (fallback to 0 if not set in DB yet)
    double price =
        double.tryParse(product['v_currentPrice']?.toString() ?? '0') ?? 0.0;

    final String sku = product['v_productCode'] ?? 'N/A';

    final String name = product['v_productName'] ?? 'Unknown Product';
    final String description =
        product['v_productDescription'] ?? 'No description available';

    final double stockQuantity =
        double.tryParse(product['v_quantityAvailable']?.toString() ?? '0') ?? 0;

    final String status;

    if (stockQuantity <= 0) {
      status = 'OUT OF STOCK';
    } else if (stockQuantity <= 5) {
      status = 'LOW STOCK';
    } else {
      status = 'AVAILABLE';
    }

    final String imageUrl =
        'https://upload.wikimedia.org/wikipedia/commons/7/7e/A_Fire_Extinguisher.jpg';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double totalPrice = price * quantity;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              sku,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.brand,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.inkMuted,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price > 0
                            ? '₱ ${price.toStringAsFixed(2)}'
                            : 'Price on request',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Availability / Stock Status
                      _buildDetailRow('Availability', status),

                      const SizedBox(height: 16),
                      const Divider(),
                      // QUANTITY SELECTOR
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setDialogState(() => quantity--);
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (quantity < stockQuantity.floor()) {
                                    setDialogState(() => quantity++);
                                  }
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.brand,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // DELIVERY OR PICKUP
                      // TOTAL PRICE
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Total Amount',
                        '₱ ${totalPrice.toStringAsFixed(2)}',
                      ),

                      // DELIVERY OR PICKUP
                      const SizedBox(height: 12),
                      const Text(
                        'Fulfillment Option',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: fulfillmentMethod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['Delivery', 'Store Pickup'].map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => fulfillmentMethod = val);
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: status == 'OUT OF STOCK'
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  ); // Close product details
                                  _showCheckoutDialog(
                                    context,
                                    product,
                                    quantity,
                                    fulfillmentMethod,
                                    totalPrice,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'OUT OF STOCK'
                                ? Colors.grey
                                : AppColors.brand,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            status == 'OUT OF STOCK'
                                ? 'Out of Stock'
                                : 'Proceed to Checkout',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. CHECKOUT & ORDER SUMMARY FLOW
  void _showCheckoutDialog(
    BuildContext context,
    Map<String, dynamic> product,
    int quantity,
    String fulfillment,
    double totalPrice,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String paymentMethod = 'Bank Transfer';
    bool showValidationError = false;
    bool isPlacingOrder = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setCheckoutState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(0),
              backgroundColor: Colors.white,
              child: AnimatedPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.surfaceMuted),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Expanded(
                              child: Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.brand,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.canvas,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['v_productName'] ??
                                                        'Unknown Product',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product['v_productDescription'] ??
                                                        'No description available',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text('x$quantity'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                          'Fulfillment',
                                          fulfillment,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                          'Total Due',
                                          '₱ ${totalPrice.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  const Text(
                                    'Contact Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),

                                  if (fulfillment == 'Delivery') ...[
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: addressController,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        labelText: 'Delivery Address',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 24),
                                  const Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    initialValue: paymentMethod,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        [
                                              'Bank Transfer',
                                              'Cash on Delivery/Pickup',
                                            ]
                                            .map(
                                              (m) => DropdownMenuItem(
                                                value: m,
                                                child: Text(m),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setCheckoutState(
                                          () => paymentMethod = val,
                                        );
                                      }
                                    },
                                  ),
                                  if (showValidationError) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Please fill in your Name and Phone Number.',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Place Order Button
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isPlacingOrder
                                ? null
                                : () async {
                                    if (nameController.text.isEmpty ||
                                        phoneController.text.isEmpty) {
                                      setCheckoutState(() {
                                        showValidationError = true;
                                      });
                                      return;
                                    }
                                    setCheckoutState(() {
                                      isPlacingOrder = true;
                                    });

                                    try {
                                      final accessToken =
                                          await ApiClient.token();
                                      if (!context.mounted) return;

                                      if (accessToken == null ||
                                          accessToken.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please sign in before placing an order.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setCheckoutState(() {
                                          isPlacingOrder = false;
                                        });
                                        return;
                                      }

                                      final response = await http.post(
                                        Uri.parse(
                                          'http://127.0.0.1:8000/api/orders',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'Authorization':
                                              'Bearer $accessToken',
                                        },
                                        body: jsonEncode({
                                          'product_id': product['v_productId'],
                                          'customer_name': nameController.text,
                                          'email': emailController.text,
                                          'contact_number':
                                              phoneController.text,
                                          'address': addressController.text,
                                          'quantity': quantity,
                                          'fulfillment_method': fulfillment,
                                          'payment_method': paymentMethod,
                                        }),
                                      );

                                      if (response.statusCode != 201) {
                                        throw Exception(
                                          'Failed to place order: ${response.body}',
                                        );
                                      }

                                      final orderData = jsonDecode(
                                        response.body,
                                      );
                                      final orderNumber =
                                          orderData['order_number'];

                                      if (context.mounted) {
                                        Navigator.pop(
                                          context,
                                        ); // Close Checkout
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Order Placed Successfully! Ref: $orderNumber',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(
                                              seconds: 4,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      setCheckoutState(() {
                                        isPlacingOrder = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to place order:\n$e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  _buildSearchBox(),
                  _buildCategoryChips(),
                  _buildProductList(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/main', (route) => false),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Homepage'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brand,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Technical Equipment Catalog',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Browse our comprehensive range of certified fire protection and life-safety equipment.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.map((cat) {
          bool isActive = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedCategory = cat['name'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? AppColors.brandTint : Colors.white,
                borderRadius: BorderRadius.circular(KataTheme.radiusControl),
                border: Border.all(
                  color: isActive ? AppColors.brand : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isActive ? AppColors.brand : AppColors.inkMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? AppColors.brand : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load products',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'No products available.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          var products = snapshot.data!;

          // SEARCH FILTER
          if (_searchQuery.isNotEmpty) {
            products = products.where((p) {
              final name = (p['v_productName'] ?? '').toString().toLowerCase();

              final sku = (p['v_productCode'] ?? '').toString().toLowerCase();

              final description = (p['v_productDescription'] ?? '')
                  .toString()
                  .toLowerCase();

              return name.contains(_searchQuery) ||
                  sku.contains(_searchQuery) ||
                  description.contains(_searchQuery);
            }).toList();
          }

          // CATEGORY FILTER
          if (_selectedCategory != 'All') {
            products = products
                .where((p) => p['v_productCategory'] == _selectedCategory)
                .toList();
          }

          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No products in this category',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 920
                  ? 3
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              const double gridSpacing = 16;
              final double cardWidth =
                  (constraints.maxWidth - gridSpacing * (columns - 1)) /
                  columns;
              final double imageSize = constraints.maxWidth < 380 ? 76 : 90;
              return Wrap(
                spacing: gridSpacing,
                runSpacing: 24,
                children: products.map((product) {
                  final sku = product['v_productCode'] ?? 'N/A';
                  final name = product['v_productName'] ?? 'Unknown Product';
                  final double stockQuantity =
                      double.tryParse(
                        product['v_quantityAvailable']?.toString() ?? '0',
                      ) ??
                      0;

                  final String status;

                  if (stockQuantity <= 0) {
                    status = 'OUT OF STOCK';
                  } else if (stockQuantity <= 5) {
                    status = 'LOW STOCK';
                  } else {
                    status = 'AVAILABLE';
                  }

                  // NEW: Kunin ang presyo para idisplay sa card
                  double price =
                      double.tryParse(
                        product['v_currentPrice']?.toString() ?? '0',
                      ) ??
                      0.0;

                  final imageUrl =
                      'https://upload.wikimedia.org/wikipedia/commons/7/7e/A_Fire_Extinguisher.jpg';

                  Color statusColor = AppColors.inkMuted;

                  if (status == 'AVAILABLE') statusColor = AppColors.success;

                  if (status == 'LOW STOCK') statusColor = AppColors.warning;

                  if (status == 'OUT OF STOCK') statusColor = AppColors.danger;

                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(KataUi.radiusCard),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A12151C),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: imageSize,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: imageSize,
                                  height: 120,
                                  color: AppColors.surfaceMuted,
                                  child: const Icon(
                                    Icons.image,
                                    color: AppColors.inkFaint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          sku,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.inkFaint,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.ink,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // NEW: Price Display
                                  Text(
                                    price > 0
                                        ? '₱ ${price.toStringAsFixed(2)}'
                                        : 'Ask for Price',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.brand,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _showProductDetails(context, product),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                        side: const BorderSide(
                                          color: AppColors.divider,
                                        ),
                                        foregroundColor: AppColors.inkSoft,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'View Details & Order',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.shopping_cart_checkout,
                                            size: 12,
                                          ),
                                        ],
                                      ),
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
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.shield, color: AppColors.brand, size: 36),
          const SizedBox(height: 16),
          const Text(
            'Katala Fire Protection',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Safeguarding Lives and Assets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.inkSoft),
          const SizedBox(height: 16),
          const Text(
            '© 2026 Katala Fire Protection Product Trading.\nAll rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }
}
