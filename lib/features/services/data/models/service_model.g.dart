// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$ServiceCategoryEnumMap, json['category']),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
      providerName: json['providerName'] as String?,
      providerId: (json['providerId'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$ServiceCategoryEnumMap[instance.category]!,
      'price': instance.price,
      'notes': instance.notes,
      'providerName': instance.providerName,
      'providerId': instance.providerId,
      'userId': instance.userId,
    };

const _$ServiceCategoryEnumMap = {
  ServiceCategory.vet: 'VET',
  ServiceCategory.grooming: 'GROOMING',
  ServiceCategory.training: 'TRAINING',
  ServiceCategory.boarding: 'BOARDING',
  ServiceCategory.walking: 'WALKING',
  ServiceCategory.sitting: 'SITTING',
  ServiceCategory.vaccination: 'VACCINATION',
  ServiceCategory.other: 'OTHER',
};

CreateServiceRequest _$CreateServiceRequestFromJson(
        Map<String, dynamic> json) =>
    CreateServiceRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$ServiceCategoryEnumMap, json['category']),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateServiceRequestToJson(
        CreateServiceRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': _$ServiceCategoryEnumMap[instance.category]!,
      'price': instance.price,
      'notes': instance.notes,
    };

UpdateServiceRequest _$UpdateServiceRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateServiceRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: $enumDecodeNullable(_$ServiceCategoryEnumMap, json['category']),
      price: (json['price'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$UpdateServiceRequestToJson(
        UpdateServiceRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': _$ServiceCategoryEnumMap[instance.category],
      'price': instance.price,
      'notes': instance.notes,
    };

ServiceSearchResponse _$ServiceSearchResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceSearchResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      first: json['first'] as bool,
      last: json['last'] as bool,
    );

Map<String, dynamic> _$ServiceSearchResponseToJson(
        ServiceSearchResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'size': instance.size,
      'number': instance.number,
      'first': instance.first,
      'last': instance.last,
    };

ServiceCategoriesResponse _$ServiceCategoriesResponseFromJson(
        Map<String, dynamic> json) =>
    ServiceCategoriesResponse(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => $enumDecode(_$ServiceCategoryEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ServiceCategoriesResponseToJson(
        ServiceCategoriesResponse instance) =>
    <String, dynamic>{
      'categories':
          instance.categories.map((e) => _$ServiceCategoryEnumMap[e]!).toList(),
    };
