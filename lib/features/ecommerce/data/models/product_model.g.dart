// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: (json['id'] as num).toInt(),
      sellerId: (json['sellerId'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      notes: json['notes'] as String?,
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      images: (json['images'] as List<dynamic>?)
              ?.map(
                  (e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerId': instance.sellerId,
      'name': instance.name,
      'description': instance.description,
      'notes': instance.notes,
      'price': instance.price,
      'discount': instance.discount,
      'final_price': instance.finalPrice,
      'stock': instance.stock,
      'category': instance.category,
      'tags': instance.tags,
      'images': instance.images,
    };

ProductImageModel _$ProductImageModelFromJson(Map<String, dynamic> json) =>
    ProductImageModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      contentType: json['contentType'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$ProductImageModelToJson(ProductImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contentType': instance.contentType,
      'data': instance.data,
    };

CreateProductRequest _$CreateProductRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProductRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      discount: (json['discount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateProductRequestToJson(
        CreateProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'stockQuantity': instance.stockQuantity,
      'discount': instance.discount,
    };

UpdateProductRequest _$UpdateProductRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProductRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      notes: json['notes'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      stock: (json['stock'] as num).toInt(),
      discount: (json['discount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateProductRequestToJson(
        UpdateProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'notes': instance.notes,
      'price': instance.price,
      'category': instance.category,
      'stock': instance.stock,
      'discount': instance.discount,
    };

ProductsResponse _$ProductsResponseFromJson(Map<String, dynamic> json) =>
    ProductsResponse(
      products: (json['content'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: (json['totalElements'] as num?)?.toInt() ?? 0,
      page: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductsResponseToJson(ProductsResponse instance) =>
    <String, dynamic>{
      'content': instance.products,
      'totalElements': instance.totalCount,
      'number': instance.page,
      'size': instance.size,
      'totalPages': instance.totalPages,
      'first': instance.first,
      'last': instance.last,
      'empty': instance.empty,
    };
