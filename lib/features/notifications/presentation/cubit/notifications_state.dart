part of 'notifications_cubit.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final bool hasMore;
  final int currentPage;

  const NotificationsLoaded({
    required this.notifications,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object> get props => [notifications, hasMore, currentPage];
}

class NotificationCountLoaded extends NotificationsState {
  final int unreadCount;
  final int totalCount;

  const NotificationCountLoaded({
    required this.unreadCount,
    required this.totalCount,
  });

  @override
  List<Object> get props => [unreadCount, totalCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object> get props => [message];
}
