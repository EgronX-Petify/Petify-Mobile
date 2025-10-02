// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProviderModel _$ServiceProviderModelFromJson(
        Map<String, dynamic> json) =>
    ServiceProviderModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      contactInfo: json['contactInfo'] as String?,
    );

Map<String, dynamic> _$ServiceProviderModelToJson(
        ServiceProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'description': instance.description,
      'contactInfo': instance.contactInfo,
    };
