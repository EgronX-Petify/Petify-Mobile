class ApiConstants {
  // Base URL - you should replace this with your actual backend URL
  // Try these different URLs based on your setup:
  // For Android Emulator: 'http://10.0.2.2:8080'
  // For localhost: 'http://localhost:8080'
  // For your machine IP: 'http://YOUR_MACHINE_IP:8080'
  static const String baseUrl =
      'http://192.168.1.105:8080'; // Try this for Android emulator first

  // API Version
  static const String apiVersion = '/api/v1';

  // Full base URL with version
  static String get fullBaseUrl => '$baseUrl$apiVersion';

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';

  // User endpoints
  static const String userProfile = '/user/me';
  static const String updateProfile = '/user/me';
  static const String getUserById = '/user'; // /{userId}
  static const String uploadProfileImage = '/user/me/image';
  static const String getProfileImage = '/user/me/image'; // /{imageId}
  static const String getAllProfileImages = '/user/me/image';
  static const String deleteProfileImage = '/user/me/image'; // /{imageId}

  // Pet endpoints
  static const String pets = '/user/me/pet';
  static const String petById = '/user/me/pet'; // /{petId}
  static const String petCount = '/user/me/pet/count';
  static const String uploadPetImage = '/user/me/pet'; // /{petId}/image
  static const String getPetImage = '/user/me/pet'; // /{petId}/image/{imageId}
  static const String getAllPetImages = '/user/me/pet'; // /{petId}/image
  static const String deletePetImage =
      '/user/me/pet'; // /{petId}/image/{imageId}

  // Service endpoints (Public)
  static const String serviceSearch = '/service/search';
  static const String serviceCategories = '/service/categories';
  static const String services = '/service';
  static const String serviceById = '/service'; // /{id}
  
  // Service Provider endpoints (Public)
  static const String serviceProviders = '/provider';
  static const String serviceProviderById = '/provider'; // /{providerId}
  static const String servicesByProvider = '/provider'; // /{providerId}/service

  // Service Provider endpoints
  static const String providerServices = '/provider/me/service';
  static const String providerServiceById =
      '/provider/me/service'; // /{serviceId}
  static const String providerAppointments = '/provider/me/appointment';
  static const String providerAppointmentById =
      '/provider/me/appointment'; // /{appointmentId}
  static const String approveAppointment =
      '/provider/me/appointment'; // /{appointmentId}/approve

  // Appointment endpoints (Pet Owner)
  static const String appointments = '/user/me/appointment';
  static const String appointmentById =
      '/user/me/appointment'; // /{appointmentId}

  // E-commerce endpoints
  static const String products = '/products';
  static const String productById = '/products'; // /{productId}
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String cartItemById = '/cart/items'; // /{productId}
  static const String cartClear = '/cart/clear';
  static const String checkout = '/checkout';
  static const String orders = '/order';
  static const String orderById = '/order'; // /{orderId}

  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static const String adminPendingProviders =
      '/admin/pending-service-providers';
  static const String adminApproveProvider =
      '/admin/approve-service-provider'; // /{userId}
  static const String adminBanUser = '/admin/ban-user'; // /{userId}
  static const String adminUnbanUser = '/admin/unban-user'; // /{userId}
  static const String adminRemoveProduct =
      '/admin/remove-product'; // /{productId}
  static const String adminRemoveService =
      '/admin/remove-service'; // /{serviceId}
  static const String adminUserCounts = '/admin/user-counts';

  // Notification endpoints
  static const String notifications = '/user/me/notification';
  static const String notificationCount = '/user/me/notification/count';
  static const String markNotificationRead =
      '/user/me/notification'; // /{notificationId}
  static const String markAllNotificationsRead =
      '/user/me/notification/mark-all-read';

  // Webhook endpoints
  static const String paymobWebhook = '/webhooks/paymob';

  // Request timeout - increased for debugging
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
  };

  // Helper methods for dynamic endpoints
  static String getUserByIdUrl(int userId) => '$getUserById/$userId';
  static String getPetByIdUrl(int petId) => '$petById/$petId';
  static String getServiceByIdUrl(int serviceId) => '$serviceById/$serviceId';
  static String getAppointmentByIdUrl(int appointmentId) =>
      '$appointmentById/$appointmentId';
  
  // Service Provider URLs
  static String getServiceProviderByIdUrl(int providerId) => '$serviceProviderById/$providerId';
  static String getServicesByProviderUrl(int providerId) => '$servicesByProvider/$providerId/service';

  // Profile image URLs
  static String getProfileImageUrl(int imageId) => '$getProfileImage/$imageId';
  static String deleteProfileImageUrl(int imageId) =>
      '$deleteProfileImage/$imageId';

  // Pet image URLs
  static String uploadPetImageUrl(int petId) => '$uploadPetImage/$petId/image';
  static String getPetImageUrl(int petId, int imageId) =>
      '$getPetImage/$petId/image/$imageId';
  static String getAllPetImagesUrl(int petId) =>
      '$getAllPetImages/$petId/image';
  static String deletePetImageUrl(int petId, int imageId) =>
      '$deletePetImage/$petId/image/$imageId';

  // Provider service URLs
  static String getProviderServiceByIdUrl(int serviceId) =>
      '$providerServiceById/$serviceId';
  static String getProviderServiceAppointmentsUrl(int serviceId) =>
      '$providerServices/$serviceId/appointments';

  // Provider appointment URLs
  static String getProviderAppointmentByIdUrl(int appointmentId) =>
      '$providerAppointmentById/$appointmentId';
  static String approveAppointmentUrl(int appointmentId) =>
      '$approveAppointment/$appointmentId/approve';
  static String disapproveAppointmentUrl(int appointmentId) =>
      '$approveAppointment/$appointmentId/disapprove';
  static String rejectAppointmentUrl(int appointmentId) =>
      '$providerAppointmentById/$appointmentId/reject';
  static String completeAppointmentUrl(int appointmentId) =>
      '$providerAppointmentById/$appointmentId/complete';

  // E-commerce URLs
  static String getProductByIdUrl(int productId) => '$productById/$productId';
  static String getCartItemByIdUrl(int productId) => '$cartItemById/$productId';
  static String getOrderByIdUrl(int orderId) => '$orderById/$orderId';

  // Admin URLs
  static String adminApproveProviderUrl(int userId) =>
      '$adminApproveProvider/$userId';
  static String adminBanUserUrl(int userId) => '$adminBanUser/$userId';
  static String adminUnbanUserUrl(int userId) => '$adminUnbanUser/$userId';
  static String adminRemoveProductUrl(int productId) =>
      '$adminRemoveProduct/$productId';
  static String adminRemoveServiceUrl(int serviceId) =>
      '$adminRemoveService/$serviceId';

  // Notification URLs
  static String markNotificationReadUrl(int notificationId) =>
      '$markNotificationRead/$notificationId';
}
