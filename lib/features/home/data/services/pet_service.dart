import 'package:dio/dio.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';

class PetService extends BaseApiService {
  
  Future<List<Map<String, dynamic>>> getUserPets() async {
    try {
      final response = await dio.get(ApiConstants.pets);
      return handleListResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getPetById(int petId) async {
    try {
      final response = await dio.get('${ApiConstants.petById}/$petId');
      return handleResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createPet(Map<String, dynamic> petData) async {
    try {
      final response = await dio.post(
        ApiConstants.pets,
        data: petData,
      );
      return handleResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updatePet(int petId, Map<String, dynamic> petData) async {
    try {
      final response = await dio.put(
        '${ApiConstants.petById}/$petId',
        data: petData,
      );
      return handleResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<void> deletePet(int petId) async {
    try {
      await dio.delete('${ApiConstants.petById}/$petId');
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<int> getPetCount() async {
    try {
      final response = await dio.get(ApiConstants.petCount);
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
