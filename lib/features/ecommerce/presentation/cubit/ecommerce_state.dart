part of 'ecommerce_cubit.dart';

abstract class EcommerceState {}

class EcommerceInitial extends EcommerceState {}

class EcommerceLoading extends EcommerceState {}

class EcommerceError extends EcommerceState {
  final String message;
  EcommerceError(this.message);
}

// Product states
class ProductsLoaded extends EcommerceState {
  final List<ProductModel> products;
  ProductsLoaded(this.products);
}

class ProductLoaded extends EcommerceState {
  final ProductModel product;
  ProductLoaded(this.product);
}

// Cart states
class CartLoaded extends EcommerceState {
  final CartModel cart;
  CartLoaded(this.cart);
}

class CartCleared extends EcommerceState {}

// Order states
class OrdersLoaded extends EcommerceState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}

class OrderLoaded extends EcommerceState {
  final OrderModel order;
  OrderLoaded(this.order);
}

class OrderCreated extends EcommerceState {
  final OrderModel order;
  OrderCreated(this.order);
}
