import 'dart:io';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

abstract class PetRepository {
  Future<List<PetModel>> getPets();
  Future<PetModel> getPetById(int petId);
  Future<PetModel> createPet(CreatePetRequest request);
  Future<PetModel> updatePet(int petId, UpdatePetRequest request);
  Future<void> deletePet(int petId);
  Future<int> getPetCount();
  Future<PetImageModel> uploadPetImage(int petId, String filePath);
  Future<List<PetImageModel>> uploadPetImages(int petId, List<File> images);
  Future<PetImageModel> getPetImage(int petId, int imageId);
  Future<List<PetImageModel>> getAllPetImages(int petId);
  Future<void> deletePetImage(int petId, int imageId);
}

class PetRepositoryImpl implements PetRepository {
  final PetService _petService;

  PetRepositoryImpl(this._petService);

  @override
  Future<List<PetModel>> getPets() async {
    try {
      return await _petService.getPets();
    } catch (e) {
      throw Exception('Failed to get pets: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> getPetById(int petId) async {
    try {
      return await _petService.getPetById(petId);
    } catch (e) {
      throw Exception('Failed to get pet: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> createPet(CreatePetRequest request) async {
    try {
      return await _petService.createPet(request);
    } catch (e) {
      throw Exception('Failed to create pet: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> updatePet(int petId, UpdatePetRequest request) async {
    try {
      return await _petService.updatePet(petId, request);
    } catch (e) {
      throw Exception('Failed to update pet: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePet(int petId) async {
    try {
      await _petService.deletePet(petId);
    } catch (e) {
      throw Exception('Failed to delete pet: ${e.toString()}');
    }
  }

  @override
  Future<int> getPetCount() async {
    try {
      return await _petService.getPetCount();
    } catch (e) {
      throw Exception('Failed to get pet count: ${e.toString()}');
    }
  }

  @override
  Future<PetImageModel> uploadPetImage(int petId, String filePath) async {
    try {
      return await _petService.uploadPetImage(petId, filePath);
    } catch (e) {
      throw Exception('Failed to upload pet image: ${e.toString()}');
    }
  }

  @override
  Future<List<PetImageModel>> uploadPetImages(int petId, List<File> images) async {
    try {
      final List<PetImageModel> uploadedImages = [];
      for (final image in images) {
        final uploadedImage = await _petService.uploadPetImage(petId, image.path);
        uploadedImages.add(uploadedImage);
      }
      return uploadedImages;
    } catch (e) {
      throw Exception('Failed to upload pet images: ${e.toString()}');
    }
  }

  @override
  Future<PetImageModel> getPetImage(int petId, int imageId) async {
    try {
      return await _petService.getPetImage(petId, imageId);
    } catch (e) {
      throw Exception('Failed to get pet image: ${e.toString()}');
    }
  }

  @override
  Future<List<PetImageModel>> getAllPetImages(int petId) async {
    try {
      return await _petService.getAllPetImages(petId);
    } catch (e) {
      throw Exception('Failed to get pet images: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePetImage(int petId, int imageId) async {
    try {
      await _petService.deletePetImage(petId, imageId);
    } catch (e) {
      throw Exception('Failed to delete pet image: ${e.toString()}');
    }
  }
}
