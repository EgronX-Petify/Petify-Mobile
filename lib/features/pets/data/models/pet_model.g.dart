// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetModel _$PetModelFromJson(Map<String, dynamic> json) => PetModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$PetTypeEnumMap, json['species']),
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      birthDate: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecodeNullable(_$PetGenderEnumMap, json['gender']),
      weight: (json['weight'] as num?)?.toDouble(),
      color: json['color'] as String?,
      description: json['description'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      isVaccinated: json['isVaccinated'] as bool?,
      isNeutered: json['isNeutered'] as bool?,
      microchipId: json['microchipId'] as String?,
      ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => PetImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PetModelToJson(PetModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': _$PetTypeEnumMap[instance.type]!,
      'breed': instance.breed,
      'age': instance.age,
      'dateOfBirth': instance.birthDate?.toIso8601String(),
      'gender': _$PetGenderEnumMap[instance.gender],
      'weight': instance.weight,
      'color': instance.color,
      'description': instance.description,
      'medicalNotes': instance.medicalNotes,
      'isVaccinated': instance.isVaccinated,
      'isNeutered': instance.isNeutered,
      'microchipId': instance.microchipId,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'images': instance.images,
    };

const _$PetTypeEnumMap = {
  PetType.dog: 'DOG',
  PetType.cat: 'CAT',
  PetType.bird: 'BIRD',
  PetType.fish: 'FISH',
  PetType.rabbit: 'RABBIT',
  PetType.hamster: 'HAMSTER',
  PetType.guineaPig: 'GUINEA_PIG',
  PetType.reptile: 'REPTILE',
  PetType.horse: 'HORSE',
  PetType.other: 'OTHER',
};

const _$PetGenderEnumMap = {
  PetGender.male: 'MALE',
  PetGender.female: 'FEMALE',
  PetGender.unknown: 'UNKNOWN',
};

PetImageModel _$PetImageModelFromJson(Map<String, dynamic> json) =>
    PetImageModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      contentType: json['contentType'] as String?,
      data: json['data'] as String?,
      petId: (json['petId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PetImageModelToJson(PetImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contentType': instance.contentType,
      'data': instance.data,
      'petId': instance.petId,
    };

CreatePetRequest _$CreatePetRequestFromJson(Map<String, dynamic> json) =>
    CreatePetRequest(
      name: json['name'] as String,
      type: $enumDecode(_$PetTypeEnumMap, json['species']),
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      birthDate: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecodeNullable(_$PetGenderEnumMap, json['gender']),
      weight: (json['weight'] as num?)?.toDouble(),
      color: json['color'] as String?,
      description: json['description'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      isVaccinated: json['isVaccinated'] as bool?,
      isNeutered: json['isNeutered'] as bool?,
      microchipId: json['microchipId'] as String?,
    );

Map<String, dynamic> _$CreatePetRequestToJson(CreatePetRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'species': _$PetTypeEnumMap[instance.type]!,
      'breed': instance.breed,
      'age': instance.age,
      'dateOfBirth': instance.birthDate?.toIso8601String(),
      'gender': _$PetGenderEnumMap[instance.gender],
      'weight': instance.weight,
      'color': instance.color,
      'description': instance.description,
      'medicalNotes': instance.medicalNotes,
      'isVaccinated': instance.isVaccinated,
      'isNeutered': instance.isNeutered,
      'microchipId': instance.microchipId,
    };

UpdatePetRequest _$UpdatePetRequestFromJson(Map<String, dynamic> json) =>
    UpdatePetRequest(
      name: json['name'] as String?,
      type: $enumDecodeNullable(_$PetTypeEnumMap, json['type']),
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      gender: $enumDecodeNullable(_$PetGenderEnumMap, json['gender']),
      weight: (json['weight'] as num?)?.toDouble(),
      color: json['color'] as String?,
      description: json['description'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      isVaccinated: json['isVaccinated'] as bool?,
      isNeutered: json['isNeutered'] as bool?,
      microchipId: json['microchipId'] as String?,
    );

Map<String, dynamic> _$UpdatePetRequestToJson(UpdatePetRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$PetTypeEnumMap[instance.type],
      'breed': instance.breed,
      'age': instance.age,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': _$PetGenderEnumMap[instance.gender],
      'weight': instance.weight,
      'color': instance.color,
      'description': instance.description,
      'medicalNotes': instance.medicalNotes,
      'isVaccinated': instance.isVaccinated,
      'isNeutered': instance.isNeutered,
      'microchipId': instance.microchipId,
    };

PetCountResponse _$PetCountResponseFromJson(Map<String, dynamic> json) =>
    PetCountResponse(
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$PetCountResponseToJson(PetCountResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
    };
