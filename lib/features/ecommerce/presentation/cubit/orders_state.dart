part of 'orders_cubit.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final bool hasMore;
  final int currentPage;

  const OrdersLoaded({
    required this.orders,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object> get props => [orders, hasMore, currentPage];
}

class OrderDetailsLoaded extends OrdersState {
  final OrderModel order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}
