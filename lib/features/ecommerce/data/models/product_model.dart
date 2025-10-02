import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final int sellerId;
  final String name;
  final String description;
  final String? notes;
  final double price;
  final double? discount;
  @JsonKey(name: 'final_price')
  final double finalPrice;
  final int stock;
  final String? category;
  final List<String> tags;
  @JsonKey(defaultValue: <ProductImageModel>[])
  final List<ProductImageModel> images;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    this.notes,
    required this.price,
    this.discount,
    required this.finalPrice,
    required this.stock,
    this.category,
    required this.tags,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  bool get hasDiscount => discount != null && discount! > 0;
  bool get inStock => stock > 0;
  int get stockQuantity => stock;
}

@JsonSerializable()
class ProductImageModel {
  final int id;
  final String name;
  final String contentType;
  final String data; // Base64 encoded image data
  
  const ProductImageModel({
    required this.id,
    required this.name,
    required this.contentType,
    required this.data,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) => _$ProductImageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageModelToJson(this);
  
  // Helper getter to get image URL from base64 data
  String get imageUrl => 'data:$contentType;base64,$data';
}

@JsonSerializable()
class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final String category;
  final int stockQuantity;
  final double? discount;

  const CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stockQuantity,
    this.discount,
  });

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) => _$CreateProductRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProductRequestToJson(this);
}

@JsonSerializable()
class UpdateProductRequest {
  final String name;
  final String description;
  final String? notes;
  final double price;
  final String category;
  final int stock;
  final double? discount;

  const UpdateProductRequest({
    required this.name,
    required this.description,
    this.notes,
    required this.price,
    required this.category,
    required this.stock,
    this.discount,
  });

  factory UpdateProductRequest.fromJson(Map<String, dynamic> json) => _$UpdateProductRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProductRequestToJson(this);
}

@JsonSerializable()
class ProductsResponse {
  @JsonKey(name: 'content', defaultValue: <ProductModel>[])
  final List<ProductModel> products;
  @JsonKey(name: 'totalElements', defaultValue: 0)
  final int totalCount;
  @JsonKey(name: 'number', defaultValue: 0)
  final int page;
  @JsonKey(defaultValue: 0)
  final int size;
  @JsonKey(defaultValue: 0)
  final int totalPages;
  @JsonKey(defaultValue: true)
  final bool first;
  @JsonKey(defaultValue: true)
  final bool last;
  @JsonKey(defaultValue: true)
  final bool empty;

  const ProductsResponse({
    required this.products,
    required this.totalCount,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);
}
