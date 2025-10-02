import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../authentication/data/models/user_model.dart';

class UserService extends BaseApiService {
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get(ApiConstants.userProfile);
      return handleResponse(response, (json) => UserModel.fromJson(json));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await dio.put(
        ApiConstants.updateProfile,
        data: userData,
      );
      return handleResponse(response, (json) => UserModel.fromJson(json));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await dio.get('${ApiConstants.getUserById}/$userId');
      return handleResponse(response, (json) => UserModel.fromJson(json));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<UserImageModel> uploadProfileImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiConstants.uploadProfileImage,
        data: formData,
        options: Options(headers: ApiConstants.multipartHeaders),
      );

      return handleResponse(response, (json) => UserImageModel.fromJson(json));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<List<UserImageModel>> getAllProfileImages() async {
    try {
      final response = await dio.get(ApiConstants.getAllProfileImages);
      return handleResponse(response, (json) {
        final List<dynamic> imagesList = json as List<dynamic>;
        return imagesList
            .map((imageJson) => UserImageModel.fromJson(imageJson))
            .toList();
      });
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<UserImageModel> getProfileImage(int imageId) async {
    try {
      final response = await dio.get(ApiConstants.getProfileImageUrl(imageId));
      return handleResponse(response, (json) => UserImageModel.fromJson(json));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteProfileImage(int imageId) async {
    try {
      print('🔍 DELETE API: Calling ${ApiConstants.deleteProfileImageUrl(imageId)}');
      final response = await dio.delete(ApiConstants.deleteProfileImageUrl(imageId));
      print('🔍 DELETE API: Response status: ${response.statusCode}');
      print('🔍 DELETE API: Response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Delete failed with status ${response.statusCode}: ${response.data}');
      }
      
      handleResponse(response, (json) => json);
      print('🔍 DELETE API: Successfully processed response');
    } on DioException catch (e) {
      print('🔍 DELETE API: DioException - ${e.message}');
      print('🔍 DELETE API: Response: ${e.response?.data}');
      print('🔍 DELETE API: Status: ${e.response?.statusCode}');
      throw handleError(e);
    } catch (e) {
      print('🔍 DELETE API: General exception - $e');
      rethrow;
    }
  }
}
