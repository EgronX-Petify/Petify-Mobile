import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = DioFactory.dio;

  /// Checkout - create order from cart
  Future<OrderModel> checkout(CheckoutRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkout,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Checkout failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid checkout data or empty cart');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get orders with pagination and filters
  Future<OrdersResponse> getOrders({
    int page = 0,
    int size = 10,
    OrderStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }

      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return OrdersResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get orders: ${response.statusMessage}');
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

  /// Get order by ID
  Future<OrderModel> getOrderById(int orderId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getOrderByIdUrl(orderId),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user's order history
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final ordersResponse = await getOrders(size: 100); // Get more orders for history
      return ordersResponse.orders;
    } catch (e) {
      throw Exception('Failed to get order history: $e');
    }
  }

  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final ordersResponse = await getOrders(status: OrderStatus.pending);
      return ordersResponse.orders;
    } catch (e) {
      throw Exception('Failed to get pending orders: $e');
    }
  }
}
