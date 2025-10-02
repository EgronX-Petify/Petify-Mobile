import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderRepository {
  final OrderService _orderService;

  OrderRepository(this._orderService);

  Future<List<OrderModel>> getOrders({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _orderService.getOrders(page: page, size: size);
    return response.orders;
  }

  Future<OrderModel> getOrderById(int orderId) async {
    return await _orderService.getOrderById(orderId);
  }

  Future<OrderModel> checkout({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final request = CheckoutRequest(
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );
    return await _orderService.checkout(request);
  }
}
