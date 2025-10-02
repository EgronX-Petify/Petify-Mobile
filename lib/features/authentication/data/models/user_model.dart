import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('SERVICE_PROVIDER')
  serviceProvider,
  @JsonValue('PET_OWNER')
  petOwner,
}

enum UserStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('BANNED')
  banned,
  @JsonValue('PENDING')
  pending,
}

@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final String? contactInfo;
  final UserRole role;
  @JsonKey(defaultValue: UserStatus.active)
  final UserStatus status;
  @JsonKey(defaultValue: null)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<UserImageModel>? images;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.description,
    this.contactInfo,
    required this.role,
    this.status = UserStatus.active,
    this.createdAt,
    this.updatedAt,
    this.images,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isAdmin => role == UserRole.admin;
  bool get isServiceProvider => role == UserRole.serviceProvider;
  bool get isPetOwner => role == UserRole.petOwner;
  bool get isActive => status == UserStatus.active;
  bool get isPending => status == UserStatus.pending;
  bool get isBanned => status == UserStatus.banned;

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? address,
    String? description,
    String? contactInfo,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserImageModel>? images,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}

@JsonSerializable()
class UserImageModel {
  @JsonKey(defaultValue: 0)
  final int id;
  final String? url;
  final String? filename;
  final String? name; // API returns 'name' instead of 'filename'
  final String? contentType;
  final String? data; // Base64 image data
  @JsonKey(defaultValue: 0)
  final int userId;

  const UserImageModel({
    this.id = 0,
    this.url,
    this.filename,
    this.name,
    this.contentType,
    this.data,
    this.userId = 0,
  });

  /// Get the image URL or create data URL from base64
  String? get imageUrl {
    if (url != null && url!.isNotEmpty) {
      return url;
    }
    if (data != null && data!.isNotEmpty && contentType != null) {
      return 'data:$contentType;base64,$data';
    }
    return null;
  }

  /// Get the display filename
  String? get displayName => name ?? filename;

  factory UserImageModel.fromJson(Map<String, dynamic> json) => _$UserImageModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserImageModelToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final String? contactInfo;

  const UpdateUserRequest({
    this.name,
    this.phoneNumber,
    this.address,
    this.description,
    this.contactInfo,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final UserRole role;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String token;

  const LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class RegisterResponse {
  final String message;

  const RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  final String token;
  final String newPassword;

  const ChangePasswordRequest({
    required this.token,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordResponse {
  final String message;

  const ForgotPasswordResponse({required this.message});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);
}

@JsonSerializable()
class ChangePasswordResponse {
  final String message;

  const ChangePasswordResponse({required this.message});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) => _$ChangePasswordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String token;

  const AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
