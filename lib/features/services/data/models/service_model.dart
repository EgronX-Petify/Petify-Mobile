import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

enum ServiceCategory {
  @JsonValue('VET')
  vet,
  @JsonValue('GROOMING')
  grooming,
  @JsonValue('TRAINING')
  training,
  @JsonValue('BOARDING')
  boarding,
  @JsonValue('WALKING')
  walking,
  @JsonValue('SITTING')
  sitting,
  @JsonValue('VACCINATION')
  vaccination,
  @JsonValue('OTHER')
  other,
}

@JsonSerializable()
class ServiceModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final ServiceCategory category;
  final double price;
  final String? notes;
  final String? providerName;
  final int providerId;
  @JsonKey(name: 'userId', defaultValue: null)
  final int? userId; // The user ID of the service provider (used for API calls)

  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.notes,
    this.providerName,
    required this.providerId,
    this.userId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

  ServiceModel copyWith({
    int? id,
    String? name,
    String? description,
    ServiceCategory? category,
    double? price,
    String? notes,
    String? providerName,
    int? providerId,
    int? userId,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      providerName: providerName ?? this.providerName,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        price,
        notes,
        providerName,
        providerId,
        userId,
      ];
}

// Request models
@JsonSerializable()
class CreateServiceRequest extends Equatable {
  final String name;
  final String? description;
  final ServiceCategory category;
  final double price;
  final String? notes;

  const CreateServiceRequest({
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.notes,
  });

  factory CreateServiceRequest.fromJson(Map<String, dynamic> json) => _$CreateServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateServiceRequestToJson(this);

  @override
  List<Object?> get props => [name, description, category, price, notes];
}

@JsonSerializable()
class UpdateServiceRequest extends Equatable {
  final String? name;
  final String? description;
  final ServiceCategory? category;
  final double? price;
  final String? notes;

  const UpdateServiceRequest({
    this.name,
    this.description,
    this.category,
    this.price,
    this.notes,
  });

  factory UpdateServiceRequest.fromJson(Map<String, dynamic> json) => _$UpdateServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateServiceRequestToJson(this);

  @override
  List<Object?> get props => [name, description, category, price, notes];
}

@JsonSerializable()
class ServiceSearchResponse {
  final List<ServiceModel> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  const ServiceSearchResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory ServiceSearchResponse.fromJson(Map<String, dynamic> json) => _$ServiceSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceSearchResponseToJson(this);
}

@JsonSerializable()
class ServiceCategoriesResponse {
  final List<ServiceCategory> categories;

  const ServiceCategoriesResponse({
    required this.categories,
  });

  factory ServiceCategoriesResponse.fromJson(Map<String, dynamic> json) => _$ServiceCategoriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceCategoriesResponseToJson(this);
}
