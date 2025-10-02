import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/product_service.dart';
import '../../data/services/cart_service.dart';
import '../../data/services/order_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';

part 'ecommerce_state.dart';

class EcommerceCubit extends Cubit<EcommerceState> {
  final ProductService _productService;
  final CartService _cartService;
  final OrderService _orderService;

  EcommerceCubit({
    required ProductService productService,
    required CartService cartService,
    required OrderService orderService,
  })  : _productService = productService,
        _cartService = cartService,
        _orderService = orderService,
        super(EcommerceInitial());

  // Product operations
  Future<void> loadProducts({String? category, int limit = 10, int offset = 0}) async {
    print('🛒 EcommerceCubit: Loading products with category=$category, limit=$limit, offset=$offset');
    emit(EcommerceLoading());
    try {
      final productsResponse = await _productService.getProducts(
        category: category,
        limit: limit,
        offset: offset,
      );
      print('🛒 EcommerceCubit: Loaded ${productsResponse.products.length} products');
      emit(ProductsLoaded(productsResponse.products));
    } catch (e) {
      print('🛒 EcommerceCubit: Error loading products: $e');
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> loadProductById(int productId) async {
    emit(EcommerceLoading());
    try {
      final product = await _productService.getProductById(productId);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> searchProducts(String searchTerm) async {
    emit(EcommerceLoading());
    try {
      final products = await _productService.searchProducts(searchTerm);
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  // Cart operations
  Future<void> loadCart() async {
    emit(EcommerceLoading());
    try {
      final cart = await _cartService.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    emit(EcommerceLoading());
    try {
      final request = AddToCartRequest(productId: productId, quantity: quantity);
      final cart = await _cartService.addToCart(request);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  /// Add to cart without changing the current state (for shop screen)
  Future<bool> addToCartSilently(int productId, int quantity) async {
    try {
      final request = AddToCartRequest(productId: productId, quantity: quantity);
      await _cartService.addToCart(request);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCartItem(int productId, int quantity) async {
    emit(EcommerceLoading());
    try {
      final request = UpdateCartItemRequest(quantity: quantity);
      final cart = await _cartService.updateCartItem(productId, request);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> removeFromCart(int productId) async {
    emit(EcommerceLoading());
    try {
      final cart = await _cartService.removeFromCart(productId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> clearCart() async {
    emit(EcommerceLoading());
    try {
      await _cartService.clearCart();
      // After clearing, load the updated cart (should be empty)
      final cart = await _cartService.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  // Order operations
  Future<void> checkout(String shippingAddress, String paymentMethod) async {
    emit(EcommerceLoading());
    try {
      final request = CheckoutRequest(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      final order = await _orderService.checkout(request);
      emit(OrderCreated(order));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> loadOrders({int page = 0, int size = 10, OrderStatus? status}) async {
    emit(EcommerceLoading());
    try {
      final ordersResponse = await _orderService.getOrders(
        page: page,
        size: size,
        status: status,
      );
      emit(OrdersLoaded(ordersResponse.orders));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> loadOrderById(int orderId) async {
    emit(EcommerceLoading());
    try {
      final order = await _orderService.getOrderById(orderId);
      emit(OrderLoaded(order));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> loadOrderHistory() async {
    emit(EcommerceLoading());
    try {
      final orders = await _orderService.getOrderHistory();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }

  Future<void> loadPendingOrders() async {
    emit(EcommerceLoading());
    try {
      final orders = await _orderService.getPendingOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(EcommerceError(e.toString()));
    }
  }
}
