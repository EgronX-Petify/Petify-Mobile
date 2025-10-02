import 'package:json_annotation/json_annotation.dart';

part 'pet_model.g.dart';

enum PetType {
  @JsonValue('DOG')
  dog,
  @JsonValue('CAT')
  cat,
  @JsonValue('BIRD')
  bird,
  @JsonValue('FISH')
  fish,
  @JsonValue('RABBIT')
  rabbit,
  @JsonValue('HAMSTER')
  hamster,
  @JsonValue('GUINEA_PIG')
  guineaPig,
  @JsonValue('REPTILE')
  reptile,
  @JsonValue('HORSE')
  horse,
  @JsonValue('OTHER')
  other,
}

enum PetGender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
  @JsonValue('UNKNOWN')
  unknown,
}

@JsonSerializable()
class PetModel {
  final int id;
  final String name;
  @JsonKey(name: 'species')
  final PetType type;
  final String? breed;
  final int? age;
  @JsonKey(name: 'dateOfBirth')
  final DateTime? birthDate;
  final PetGender? gender;
  final double? weight;
  final String? color;
  final String? description;
  final String? medicalNotes;
  final bool? isVaccinated;
  final bool? isNeutered;
  final String? microchipId;
  @JsonKey(defaultValue: 0)
  final int? ownerId;
  @JsonKey(defaultValue: null)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PetImageModel>? images;

  const PetModel({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.age,
    this.birthDate,
    this.gender,
    this.weight,
    this.color,
    this.description,
    this.medicalNotes,
    this.isVaccinated,
    this.isNeutered,
    this.microchipId,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.images,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) =>
      _$PetModelFromJson(json);
  Map<String, dynamic> toJson() => _$PetModelToJson(this);

  PetModel copyWith({
    int? id,
    String? name,
    PetType? type,
    String? breed,
    int? age,
    DateTime? birthDate,
    PetGender? gender,
    double? weight,
    String? color,
    String? description,
    String? medicalNotes,
    bool? isVaccinated,
    bool? isNeutered,
    String? microchipId,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PetImageModel>? images,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      description: description ?? this.description,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isNeutered: isNeutered ?? this.isNeutered,
      microchipId: microchipId ?? this.microchipId,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}

@JsonSerializable()
class PetImageModel {
  final int id;
  final String name;
  final String? contentType;
  final String? data; // base64 encoded image data
  @JsonKey(defaultValue: null)
  final int? petId;

  const PetImageModel({
    required this.id,
    required this.name,
    this.contentType,
    this.data,
    this.petId,
  });

  factory PetImageModel.fromJson(Map<String, dynamic> json) =>
      _$PetImageModelFromJson(json);
  Map<String, dynamic> toJson() => _$PetImageModelToJson(this);
}

@JsonSerializable()
class CreatePetRequest {
  final String name;
  @JsonKey(name: 'species')
  final PetType type;
  final String? breed;
  final int? age;
  @JsonKey(name: 'dateOfBirth')
  final DateTime? birthDate;
  final PetGender? gender;
  final double? weight;
  final String? color;
  final String? description;
  final String? medicalNotes;
  final bool? isVaccinated;
  final bool? isNeutered;
  final String? microchipId;

  const CreatePetRequest({
    required this.name,
    required this.type,
    this.breed,
    this.age,
    this.birthDate,
    this.gender,
    this.weight,
    this.color,
    this.description,
    this.medicalNotes,
    this.isVaccinated,
    this.isNeutered,
    this.microchipId,
  });

  factory CreatePetRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePetRequestToJson(this);
}

@JsonSerializable()
class UpdatePetRequest {
  final String? name;
  final PetType? type;
  final String? breed;
  final int? age;
  final DateTime? birthDate;
  final PetGender? gender;
  final double? weight;
  final String? color;
  final String? description;
  final String? medicalNotes;
  final bool? isVaccinated;
  final bool? isNeutered;
  final String? microchipId;

  const UpdatePetRequest({
    this.name,
    this.type,
    this.breed,
    this.age,
    this.birthDate,
    this.gender,
    this.weight,
    this.color,
    this.description,
    this.medicalNotes,
    this.isVaccinated,
    this.isNeutered,
    this.microchipId,
  });

  factory UpdatePetRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePetRequestToJson(this);
}

@JsonSerializable()
class PetCountResponse {
  final int count;

  const PetCountResponse({required this.count});

  factory PetCountResponse.fromJson(Map<String, dynamic> json) =>
      _$PetCountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PetCountResponseToJson(this);
}
