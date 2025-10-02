import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../data/services/pet_management_service.dart';
import '../../data/models/pet_model.dart';

part 'pet_state.dart';

class PetCubit extends Cubit<PetState> {
  final PetManagementService _petService;

  PetCubit({
    required PetManagementService petService,
  })  : _petService = petService,
        super(PetInitial());

  // Pet CRUD operations
  Future<void> loadPets() async {
    emit(PetLoading());
    try {
      final pets = await _petService.getPets();
      emit(PetsLoaded(pets));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> loadPetById(int petId) async {
    emit(PetLoading());
    try {
      final pet = await _petService.getPetById(petId);
      emit(PetLoaded(pet));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> createPet(CreatePetRequest request) async {
    emit(PetLoading());
    try {
      final pet = await _petService.createPet(request);
      emit(PetCreated(pet));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> updatePet(int petId, CreatePetRequest request) async {
    emit(PetLoading());
    try {
      final pet = await _petService.updatePet(petId, request);
      emit(PetUpdated(pet));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> deletePet(int petId) async {
    emit(PetLoading());
    try {
      await _petService.deletePet(petId);
      emit(PetDeleted());
      // Reload pets after deletion
      loadPets();
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> loadPetCount() async {
    emit(PetLoading());
    try {
      final countResponse = await _petService.getPetCount();
      emit(PetCountLoaded(countResponse.count));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  // Pet image operations
  Future<void> uploadPetImage(int petId, File imageFile) async {
    emit(PetLoading());
    try {
      final image = await _petService.uploadPetImage(petId, imageFile);
      emit(PetImageUploaded(image));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> loadPetImages(int petId) async {
    emit(PetLoading());
    try {
      final images = await _petService.getPetImages(petId);
      emit(PetImagesLoaded(images));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> deletePetImage(int petId, int imageId) async {
    emit(PetLoading());
    try {
      await _petService.deletePetImage(petId, imageId);
      emit(PetImageDeleted());
      // Reload images after deletion
      loadPetImages(petId);
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  // Helper methods
  Future<void> refreshPets() async {
    await loadPets();
  }

  Future<void> loadPetWithImages(int petId) async {
    emit(PetLoading());
    try {
      // Load pet and images in parallel
      final petTask = _petService.getPetById(petId);
      final imagesTask = _petService.getPetImages(petId);
      
      final results = await Future.wait([petTask, imagesTask]);
      final pet = results[0] as PetModel;
      final images = results[1] as List<PetImageModel>;
      
      emit(PetWithImagesLoaded(pet, images));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }
}
