import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  final int id;
  final int userId;
  @JsonKey(name: 'products', defaultValue: <CartProductModel>[])
  final List<CartProductModel> products;
  @JsonKey(defaultValue: 0.0)
  final double? totalAmount;
  @JsonKey(defaultValue: null)
  final DateTime? createdAt;
  @JsonKey(defaultValue: null)
  final DateTime? updatedAt;

  const CartModel({
    required this.id,
    required this.userId,
    required this.products,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => _$CartModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  int get totalItems => products.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
  
  // For backward compatibility with existing code that expects 'items'
  List<CartProductModel> get items => products;
}

// Simple cart product model that matches API response
@JsonSerializable()
class CartProductModel {
  final int productId;
  final int quantity;

  const CartProductModel({
    required this.productId,
    required this.quantity,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) => _$CartProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartProductModelToJson(this);
}

// Full cart item model for display purposes (when we have product details)
@JsonSerializable()
class CartItemModel {
  final int id;
  final int productId;
  final ProductModel product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
}

@JsonSerializable()
class AddToCartRequest {
  final int productId;
  final int quantity;

  const AddToCartRequest({
    required this.productId,
    required this.quantity,
  });

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) => _$AddToCartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddToCartRequestToJson(this);
}

@JsonSerializable()
class UpdateCartItemRequest {
  final int quantity;

  const UpdateCartItemRequest({
    required this.quantity,
  });

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) => _$UpdateCartItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}
