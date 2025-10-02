import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = DioFactory.dio;

  /// Get all products with optional filters
  Future<ProductsResponse> getProducts({
    String? category,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      print('🛒 ProductService: Making request to ${ApiConstants.products} with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      print('🛒 ProductService: Response status: ${response.statusCode}');
      print('🛒 ProductService: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Handle both array response and structured response
        if (response.data is List) {
          print('🛒 ProductService: Processing array response');
          // If API returns a simple array of products
          final List<dynamic> productsJson = response.data;
          final List<ProductModel> products = [];
          
          for (int i = 0; i < productsJson.length; i++) {
            try {
              final json = productsJson[i];
              print('🛒 ProductService: Processing product $i: ${json['name']}');
              final product = ProductModel.fromJson(json);
              products.add(product);
            } catch (e) {
              print('🛒 ProductService: Error parsing product $i: $e');
              print('🛒 ProductService: Product data: ${productsJson[i]}');
              // Skip this product and continue with others
            }
          }
          
          return ProductsResponse(
            products: products,
            totalCount: products.length,
            page: 0,
            size: products.length,
            totalPages: 1,
            first: true,
            last: true,
            empty: products.isEmpty,
          );
        } else {
          print('🛒 ProductService: Processing structured response');
          // If API returns structured response (Spring Boot pageable)
          try {
            final result = ProductsResponse.fromJson(response.data);
            print('🛒 ProductService: Parsed ${result.products.length} products from structured response');
            return result;
          } catch (e) {
            print('🛒 ProductService: Error parsing structured response: $e');
            print('🛒 ProductService: Response data: ${response.data}');
            
            // Try to parse the content array directly
            if (response.data['content'] is List) {
              final List<dynamic> productsJson = response.data['content'];
              final List<ProductModel> products = [];
              
              for (int i = 0; i < productsJson.length; i++) {
                try {
                  final json = productsJson[i];
                  print('🛒 ProductService: Processing content product $i: ${json['name']}');
                  final product = ProductModel.fromJson(json);
                  products.add(product);
                } catch (e) {
                  print('🛒 ProductService: Error parsing content product $i: $e');
                  print('🛒 ProductService: Product data: ${productsJson[i]}');
                  // Skip this product and continue with others
                }
              }
              
              return ProductsResponse(
                products: products,
                totalCount: response.data['totalElements'] ?? products.length,
                page: response.data['number'] ?? 0,
                size: response.data['size'] ?? products.length,
                totalPages: response.data['totalPages'] ?? 1,
                first: response.data['first'] ?? true,
                last: response.data['last'] ?? true,
                empty: response.data['empty'] ?? products.isEmpty,
              );
            }
            
            throw e;
          }
        }
      } else {
        throw Exception('Failed to get products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 ProductService: DioException: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 ProductService: Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(int productId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getProductByIdUrl(productId),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create new product (requires authentication)
  Future<ProductModel> createProduct(CreateProductRequest request) async {
    try {
      print('🛒 ProductService: Creating product: ${request.name}');
      final response = await _dio.post(
        ApiConstants.products,
        data: request.toJson(),
      );
      print('🛒 ProductService: Create product response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 ProductService: DioException creating product: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid product data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 ProductService: Unexpected error creating product: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update existing product (requires authentication and ownership)
  Future<ProductModel> updateProduct(int productId, UpdateProductRequest request) async {
    try {
      print('🛒 ProductService: Updating product $productId: ${request.name}');
      final response = await _dio.put(
        ApiConstants.getProductByIdUrl(productId),
        data: request.toJson(),
      );
      print('🛒 ProductService: Update product response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 ProductService: DioException updating product: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid product data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied - you can only update your own products');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 ProductService: Unexpected error updating product: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete product (requires authentication and ownership)
  Future<void> deleteProduct(int productId) async {
    try {
      print('🛒 ProductService: Deleting product $productId');
      final response = await _dio.delete(
        ApiConstants.getProductByIdUrl(productId),
      );
      print('🛒 ProductService: Delete product response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 ProductService: DioException deleting product: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied - you can only delete your own products');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 ProductService: Unexpected error deleting product: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get products by seller (service provider's own products)
  Future<List<ProductModel>> getMyProducts() async {
    try {
      print('🛒 ProductService: Getting my products');
      final response = await _dio.get('${ApiConstants.products}/my-products');
      print('🛒 ProductService: My products response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> productsJson = response.data;
          return productsJson.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          final result = ProductsResponse.fromJson(response.data);
          return result.products;
        }
      } else {
        throw Exception('Failed to get my products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🛒 ProductService: DioException getting my products: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🛒 ProductService: Unexpected error getting my products: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Search products by name or description
  Future<List<ProductModel>> searchProducts(String searchTerm) async {
    try {
      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: {'search': searchTerm},
      );

      if (response.statusCode == 200) {
        final productsResponse = ProductsResponse.fromJson(response.data);
        return productsResponse.products;
      } else {
        throw Exception('Failed to search products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Upload image for a product (requires authentication and service provider role)
  Future<ProductImageModel> uploadProductImage(int productId, File imageFile) async {
    try {
      print('🖼️ ProductService: Uploading image for product $productId');
      
      // Create form data with the image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '${ApiConstants.products}/$productId/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('🖼️ ProductService: Image upload response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductImageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🖼️ ProductService: DioException during image upload: ${e.message}');
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid image file');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied - only service providers can upload images');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🖼️ ProductService: Unexpected error during image upload: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Upload multiple images for a product
  Future<List<ProductImageModel>> uploadProductImages(int productId, List<File> imageFiles) async {
    final List<ProductImageModel> uploadedImages = [];
    
    for (final imageFile in imageFiles) {
      try {
        final uploadedImage = await uploadProductImage(productId, imageFile);
        uploadedImages.add(uploadedImage);
      } catch (e) {
        print('🖼️ ProductService: Failed to upload image ${imageFile.path}: $e');
        // Continue with other images even if one fails
      }
    }
    
    return uploadedImages;
  }

  /// Delete product image (requires authentication and service provider role)
  Future<void> deleteProductImage(int productId, int imageId) async {
    try {
      print('🗑️ ProductService: Deleting image $imageId for product $productId');
      
      final response = await _dio.delete(
        '${ApiConstants.products}/$productId/image/$imageId',
      );

      print('🗑️ ProductService: Delete image response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('🗑️ ProductService: DioException during image deletion: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied - only service providers can delete images');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Image or product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🗑️ ProductService: Unexpected error during image deletion: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
