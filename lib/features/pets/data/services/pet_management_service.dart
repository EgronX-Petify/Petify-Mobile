import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pet_model.dart';

class PetManagementService {
  final Dio _dio = DioFactory.dio;

  /// Get all pets for current user
  Future<List<PetModel>> getPets() async {
    try {
      print('🐾 PetManagementService: Getting pets from ${ApiConstants.pets}');
      final response = await _dio.get(ApiConstants.pets);

      print('🐾 PetManagementService: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> petsJson = response.data;
        print('🐾 PetManagementService: Successfully loaded ${petsJson.length} pets');
        return petsJson.map((json) => PetModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pets: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🐾 PetManagementService: DioException - Status: ${e.response?.statusCode}');
      print('🐾 PetManagementService: Error data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 500) {
        // Handle server errors gracefully (e.g., file storage issues)
        print('🐾 PetManagementService: Server error detected - likely file storage issue');
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          if (errorData['message'].toString().contains('FileStorageException') ||
              errorData['message'].toString().contains('Failed to load file')) {
            throw Exception('Some pet images could not be loaded. Please try refreshing or contact support if the issue persists.');
          }
        }
        throw Exception('Server error occurred while loading pets. Please try again later.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🐾 PetManagementService: Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get pet by ID
  Future<PetModel> getPetById(int petId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getPetByIdUrl(petId),
      );

      if (response.statusCode == 200) {
        return PetModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create new pet
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
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Pet owner role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update pet
  Future<PetModel> updatePet(int petId, CreatePetRequest request) async {
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
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid pet data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete pet
  Future<void> deletePet(int petId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.getPetByIdUrl(petId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete pet: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get pet count
  Future<PetCountResponse> getPetCount() async {
    try {
      final response = await _dio.get(ApiConstants.petCount);

      if (response.statusCode == 200) {
        return PetCountResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get pet count: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Upload pet image
  Future<PetImageModel> uploadPetImage(int petId, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'petId': petId.toString(),
      });

      final response = await _dio.post(
        ApiConstants.uploadPetImageUrl(petId),
        data: formData,
      );

      if (response.statusCode == 201) {
        return PetImageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid image file');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all pet images
  Future<List<PetImageModel>> getPetImages(int petId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getAllPetImagesUrl(petId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> imagesJson = response.data;
        return imagesJson.map((json) => PetImageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pet images: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete pet image
  Future<void> deletePetImage(int petId, int imageId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deletePetImageUrl(petId, imageId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Image not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
