import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  final Dio _dio = DioFactory.dio;

  /// Get current user's cart
  Future<CartModel> getCart() async {
    try {
      final response = await _dio.get(ApiConstants.cart);

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add item to cart
  Future<CartModel> addToCart(AddToCartRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.cartItems,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception('Failed to add to cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid product or quantity');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update cart item quantity
  Future<CartModel> updateCartItem(int productId, UpdateCartItemRequest request) async {
    try {
      print('🛒 CartService: Updating cart item $productId with quantity ${request.quantity}');
      final response = await _dio.put(
        ApiConstants.getCartItemByIdUrl(productId),
        data: request.toJson(),
      );
      print('🛒 CartService: Update response status: ${response.statusCode}');
      print('🛒 CartService: Update response data: ${response.data}');

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update cart item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 CartService: DioException updating cart item: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid quantity');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Cart item not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 CartService: Unexpected error updating cart item: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove item from cart
  Future<CartModel> removeFromCart(int productId) async {
    try {
      print('🛒 CartService: Removing cart item $productId');
      final response = await _dio.post(
        '${ApiConstants.cart}/remove/$productId',
      );
      print('🛒 CartService: Remove response status: ${response.statusCode}');
      print('🛒 CartService: Remove response data: ${response.data}');

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception('Failed to remove from cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 CartService: DioException removing cart item: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Cart item not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 CartService: Unexpected error removing cart item: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      print('🛒 CartService: Clearing entire cart');
      final response = await _dio.delete(ApiConstants.cartClear);
      print('🛒 CartService: Clear cart response status: ${response.statusCode}');
      print('🛒 CartService: Clear cart response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 CartService: DioException clearing cart: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 CartService: Unexpected error clearing cart: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
