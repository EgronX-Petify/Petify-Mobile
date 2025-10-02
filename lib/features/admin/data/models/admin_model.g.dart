// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUsersResponse _$AdminUsersResponseFromJson(Map<String, dynamic> json) =>
    AdminUsersResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$AdminUsersResponseToJson(AdminUsersResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'totalCount': instance.totalCount,
    };

PendingServiceProvidersResponse _$PendingServiceProvidersResponseFromJson(
        Map<String, dynamic> json) =>
    PendingServiceProvidersResponse(
      pendingProviders: (json['pendingProviders'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$PendingServiceProvidersResponseToJson(
        PendingServiceProvidersResponse instance) =>
    <String, dynamic>{
      'pendingProviders': instance.pendingProviders,
      'totalCount': instance.totalCount,
    };

UserCountsResponse _$UserCountsResponseFromJson(Map<String, dynamic> json) =>
    UserCountsResponse(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      bannedUsers: (json['bannedUsers'] as num).toInt(),
      pendingServiceProviders: (json['pendingServiceProviders'] as num).toInt(),
      totalPetOwners: (json['totalPetOwners'] as num).toInt(),
      totalServiceProviders: (json['totalServiceProviders'] as num).toInt(),
      totalAdmins: (json['totalAdmins'] as num).toInt(),
    );

Map<String, dynamic> _$UserCountsResponseToJson(UserCountsResponse instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'bannedUsers': instance.bannedUsers,
      'pendingServiceProviders': instance.pendingServiceProviders,
      'totalPetOwners': instance.totalPetOwners,
      'totalServiceProviders': instance.totalServiceProviders,
      'totalAdmins': instance.totalAdmins,
    };

AdminActionResponse _$AdminActionResponseFromJson(Map<String, dynamic> json) =>
    AdminActionResponse(
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$AdminActionResponseToJson(
        AdminActionResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
    };
