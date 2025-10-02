import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/order_model.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _repository;

  OrdersCubit(this._repository) : super(OrdersInitial());

  Future<void> loadOrders({
    int page = 0,
    int size = 10,
  }) async {
    try {
      emit(OrdersLoading());
      
      final orders = await _repository.getOrders(
        page: page,
        size: size,
      );
      
      emit(OrdersLoaded(
        orders: orders,
        hasMore: orders.length == size,
        currentPage: page,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> loadMoreOrders() async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      if (!currentState.hasMore) return;

      try {
        final orders = await _repository.getOrders(
          page: currentState.currentPage + 1,
          size: 10,
        );

        emit(OrdersLoaded(
          orders: [...currentState.orders, ...orders],
          hasMore: orders.length == 10,
          currentPage: currentState.currentPage + 1,
        ));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    }
  }

  Future<void> getOrderById(int orderId) async {
    try {
      emit(OrdersLoading());
      final order = await _repository.getOrderById(orderId);
      emit(OrderDetailsLoaded(order));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
