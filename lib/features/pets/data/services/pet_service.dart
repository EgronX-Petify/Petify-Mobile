import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pet_model.dart';

class PetService {
  final Dio _dio = DioFactory.dio;

  // Get all pets for current user
  Future<List<PetModel>> getPets() async {
    try {
      final response = await _dio.get(ApiConstants.pets);

      if (response.statusCode == 200) {
        final List<dynamic> petsJson = response.data;
        return petsJson.map((json) => PetModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pets: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get pet by ID
  Future<PetModel> getPetById(int petId) async {
    try {
      final response = await _dio.get(ApiConstants.getPetByIdUrl(petId));

      if (response.statusCode == 200) {
        return PetModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Create new pet
  Future<PetModel> createPet(CreatePetRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.pets,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return PetModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid pet data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Update pet
  Future<PetModel> updatePet(int petId, UpdatePetRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.getPetByIdUrl(petId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PetModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid pet data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete pet
  Future<void> deletePet(int petId) async {
    try {
      final response = await _dio.delete(ApiConstants.getPetByIdUrl(petId));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get pet count
  Future<int> getPetCount() async {
    try {
      final response = await _dio.get(ApiConstants.petCount);

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        throw Exception('Failed to get pet count: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Upload pet image
  Future<PetImageModel> uploadPetImage(int petId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        ApiConstants.uploadPetImageUrl(petId),
        data: formData,
        options: Options(headers: ApiConstants.multipartHeaders),
      );

      if (response.statusCode == 200) {
        return PetImageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get pet image by ID
  Future<PetImageModel> getPetImage(int petId, int imageId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getPetImageUrl(petId, imageId),
      );

      if (response.statusCode == 200) {
        return PetImageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Image not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all pet images
  Future<List<PetImageModel>> getAllPetImages(int petId) async {
    try {
      final response = await _dio.get(ApiConstants.getAllPetImagesUrl(petId));

      if (response.statusCode == 200) {
        final List<dynamic> imagesJson = response.data;
        return imagesJson.map((json) => PetImageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get images: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete pet image
  Future<void> deletePetImage(int petId, int imageId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deletePetImageUrl(petId, imageId),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Image not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
