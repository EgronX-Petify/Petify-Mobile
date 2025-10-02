import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/ecommerce_cubit.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';
import '../../../../core/services/service_locator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Map<int, ProductModel> _productCache = {};

  @override
  void initState() {
    super.initState();
    // Only load cart if not already loaded
    final cubit = context.read<EcommerceCubit>();
    if (cubit.state is! CartLoaded) {
      cubit.loadCart();
    }
  }

  Future<ProductModel?> _getProduct(int productId) async {
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    try {
      final productService = sl<ProductService>();
      final product = await productService.getProductById(productId);
      _productCache[productId] = product;
      return product;
    } catch (e) {
      print('Error loading product $productId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          BlocBuilder<EcommerceCubit, EcommerceState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocBuilder<EcommerceCubit, EcommerceState>(
          builder: (context, state) {
            if (state is EcommerceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is EcommerceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading cart',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => context.read<EcommerceCubit>().loadCart(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CartLoaded) {
              if (state.cart.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 120,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your cart is empty',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.grey700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add some products to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.pushReplacement('/shop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Start Shopping'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Cart Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.cart.products.length,
                      itemBuilder: (context, index) {
                        final cartProduct = state.cart.products[index];
                        return FutureBuilder<ProductModel?>(
                          future: _getProduct(cartProduct.productId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final product = snapshot.data;
                            if (product == null) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  child: const Center(
                                    child: Text(
                                      'Product not found',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return _buildCartItem(cartProduct, product);
                          },
                        );
                      },
                    ),
                  ),

                  // Cart Summary
                  _buildCartSummary(state.cart),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(cartProduct, ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.grey200,
              ),
              child:
                  product.images.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(product.images.first.data),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.pets,
                                color: AppColors.grey400,
                                size: 32,
                              ),
                        ),
                      )
                      : Icon(Icons.pets, color: AppColors.grey400, size: 32),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(color: AppColors.grey600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          () => _decrementQuantity(
                            cartProduct.productId,
                            cartProduct.quantity,
                          ),
                      icon: const Icon(Icons.remove, color: AppColors.grey600),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cartProduct.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () => _incrementQuantity(
                            cartProduct.productId,
                            cartProduct.quantity,
                          ),
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total: \$${(product.price * cartProduct.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeItem(cartProduct.productId),
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.error,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      tooltip: 'Remove item',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(cart) {
    double totalAmount = 0.0;
    int totalItems = 0;
    int loadedProducts = 0;

    // Calculate total from cached products only
    for (final cartProduct in cart.products) {
      final product = _productCache[cartProduct.productId];
      if (product != null) {
        totalAmount += product.price * cartProduct.quantity;
        totalItems += (cartProduct.quantity as int);
        loadedProducts++;
      }
    }

    // If not all products are loaded yet, use cart's totalItems as fallback
    if (loadedProducts < cart.products.length) {
      totalItems = cart.totalItems; // Use cart's built-in totalItems
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items ($totalItems)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shipping',
                  style: TextStyle(fontSize: 16, color: AppColors.grey600),
                ),
                Text(
                  totalAmount > 50 ? 'FREE' : '\$5.00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totalAmount > 50 ? AppColors.success : null,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${(totalAmount + (totalAmount > 50 ? 0 : 5)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: totalItems > 0 ? _proceedToCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementQuantity(int productId, int currentQuantity) {
    final newQuantity = currentQuantity + 1;
    context.read<EcommerceCubit>().updateCartItem(productId, newQuantity);
  }

  void _decrementQuantity(int productId, int currentQuantity) {
    if (currentQuantity > 1) {
      final newQuantity = currentQuantity - 1;
      context.read<EcommerceCubit>().updateCartItem(productId, newQuantity);
    } else {
      // If quantity is 1, remove the item completely
      _removeItem(productId);
    }
  }

  void _removeItem(int productId) {
    context.read<EcommerceCubit>().removeFromCart(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<EcommerceCubit>().clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }

  void _proceedToCheckout() {
    // TODO: Implement checkout functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checkout functionality coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
