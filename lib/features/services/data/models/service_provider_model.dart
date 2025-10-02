import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_provider_model.g.dart';

@JsonSerializable()
class ServiceProviderModel extends Equatable {
  final int id;
  final String? name; // Made nullable to handle API returning null
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final String? contactInfo;

  const ServiceProviderModel({
    required this.id,
    this.name, // No longer required since it can be null
    required this.email,
    this.phoneNumber,
    this.address,
    this.description,
    this.contactInfo,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderModelToJson(this);

  ServiceProviderModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? description,
    String? contactInfo,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        address,
        description,
        contactInfo,
      ];
}
