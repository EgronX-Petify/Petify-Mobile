import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';

part 'order_model.g.dart';

enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('SHIPPED')
  shipped,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class OrderModel {
  final int id;
  final int userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderItemModel {
  final int id;
  final int productId;
  final ProductModel product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

@JsonSerializable()
class CheckoutRequest {
  final String shippingAddress;
  final String paymentMethod;

  const CheckoutRequest({
    required this.shippingAddress,
    required this.paymentMethod,
  });

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) => _$CheckoutRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckoutRequestToJson(this);
}

@JsonSerializable()
class OrdersResponse {
  final List<OrderModel> orders;
  final int totalCount;
  final int page;
  final int size;

  const OrdersResponse({
    required this.orders,
    required this.totalCount,
    required this.page,
    required this.size,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => _$OrdersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}
