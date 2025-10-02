import 'package:json_annotation/json_annotation.dart';
import '../../../authentication/data/models/user_model.dart';

part 'admin_model.g.dart';

@JsonSerializable()
class AdminUsersResponse {
  final List<UserModel> users;
  final int totalCount;

  const AdminUsersResponse({
    required this.users,
    required this.totalCount,
  });

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) => _$AdminUsersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdminUsersResponseToJson(this);
}

@JsonSerializable()
class PendingServiceProvidersResponse {
  final List<UserModel> pendingProviders;
  final int totalCount;

  const PendingServiceProvidersResponse({
    required this.pendingProviders,
    required this.totalCount,
  });

  factory PendingServiceProvidersResponse.fromJson(Map<String, dynamic> json) => _$PendingServiceProvidersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PendingServiceProvidersResponseToJson(this);
}

@JsonSerializable()
class UserCountsResponse {
  final int totalUsers;
  final int activeUsers;
  final int bannedUsers;
  final int pendingServiceProviders;
  final int totalPetOwners;
  final int totalServiceProviders;
  final int totalAdmins;

  const UserCountsResponse({
    required this.totalUsers,
    required this.activeUsers,
    required this.bannedUsers,
    required this.pendingServiceProviders,
    required this.totalPetOwners,
    required this.totalServiceProviders,
    required this.totalAdmins,
  });

  factory UserCountsResponse.fromJson(Map<String, dynamic> json) => _$UserCountsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserCountsResponseToJson(this);
}

@JsonSerializable()
class AdminActionResponse {
  final String message;
  final bool success;

  const AdminActionResponse({
    required this.message,
    required this.success,
  });

  factory AdminActionResponse.fromJson(Map<String, dynamic> json) => _$AdminActionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdminActionResponseToJson(this);
}
