part of 'pet_cubit.dart';

abstract class PetState {}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetError extends PetState {
  final String message;
  PetError(this.message);
}

// Pet CRUD states
class PetsLoaded extends PetState {
  final List<PetModel> pets;
  PetsLoaded(this.pets);
}

class PetLoaded extends PetState {
  final PetModel pet;
  PetLoaded(this.pet);
}

class PetCreated extends PetState {
  final PetModel pet;
  PetCreated(this.pet);
}

class PetUpdated extends PetState {
  final PetModel pet;
  PetUpdated(this.pet);
}

class PetDeleted extends PetState {}

class PetCountLoaded extends PetState {
  final int count;
  PetCountLoaded(this.count);
}

// Pet image states
class PetImagesLoaded extends PetState {
  final List<PetImageModel> images;
  PetImagesLoaded(this.images);
}

class PetImageUploaded extends PetState {
  final PetImageModel image;
  PetImageUploaded(this.image);
}

class PetImageDeleted extends PetState {}

// Combined states
class PetWithImagesLoaded extends PetState {
  final PetModel pet;
  final List<PetImageModel> images;
  
  PetWithImagesLoaded(this.pet, this.images);
}
