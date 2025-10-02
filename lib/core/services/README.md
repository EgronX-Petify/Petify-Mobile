# Petify API Services

This directory contains the API services implementation using Dio HTTP client with secure storage integration.

## Features

- **Dio Factory**: Centralized HTTP client configuration with interceptors
- **Secure Storage Integration**: Automatic token management and refresh
- **Base API Service**: Common functionality for all API services
- **Error Handling**: Consistent error handling across all services
- **Automatic Token Refresh**: Handles token expiration automatically

## Configuration

### API Constants
Update `api_constants.dart` with your backend URL:

```dart
static const String baseUrl = 'https://your-api-domain.com'; // Replace with your actual API URL
```

### Usage Examples

#### Authentication
```dart
final authService = AuthService();

// Login
try {
  final response = await authService.login({
    'email': 'user@example.com',
    'password': 'password123'
  });
  print('Login successful: ${response.user.name}');
} catch (e) {
  print('Login failed: $e');
}

// Register
try {
  final response = await authService.register({
    'username': 'newuser',
    'email': 'newuser@example.com',
    'password': 'password123',
    'role': 'PET_OWNER'
  });
  print('Registration successful: ${response.user.name}');
} catch (e) {
  print('Registration failed: $e');
}
```

#### Pet Management
```dart
final petService = PetService();

// Get user's pets
try {
  final pets = await petService.getUserPets();
  print('Found ${pets.length} pets');
} catch (e) {
  print('Failed to get pets: $e');
}

// Create a new pet
try {
  final newPet = await petService.createPet({
    'name': 'Buddy',
    'species': 'DOG',
    'breed': 'Golden Retriever',
    'gender': 'male',
    'dateOfBirth': '2020-07-12T00:00:00'
  });
  print('Pet created: ${newPet['name']}');
} catch (e) {
  print('Failed to create pet: $e');
}
```

#### User Profile
```dart
final userService = UserService();

// Get current user profile
try {
  final user = await userService.getCurrentUser();
  print('Current user: ${user.name}');
} catch (e) {
  print('Failed to get user: $e');
}

// Update profile
try {
  final updatedUser = await userService.updateProfile({
    'name': 'John Doe',
    'phoneNumber': '+1234567890',
    'address': '123 Main St, City, State'
  });
  print('Profile updated: ${updatedUser.name}');
} catch (e) {
  print('Failed to update profile: $e');
}
```

#### Service Provider
```dart
final serviceProviderService = ServiceProviderService();

// Get service categories
try {
  final categories = await serviceProviderService.getServiceCategories();
  print('Available categories: $categories');
} catch (e) {
  print('Failed to get categories: $e');
}

// Create a service
try {
  final service = await serviceProviderService.createService({
    'name': 'General Health Checkup',
    'description': 'Comprehensive health examination for pets',
    'category': 'VET',
    'price': 75.0,
    'notes': 'Includes basic examination and consultation'
  });
  print('Service created: ${service['name']}');
} catch (e) {
  print('Failed to create service: $e');
}
```

## Architecture

### Dio Factory
- Configures base URL, timeouts, and default headers
- Adds authentication interceptor for automatic token injection
- Handles token refresh automatically on 401 errors
- Includes logging interceptor for debugging

### Base API Service
- Provides common error handling
- Standardizes response parsing
- Handles both single objects and lists
- Extends this class for feature-specific services

### Secure Storage Integration
- Automatically saves and retrieves tokens
- Handles token refresh logic
- Clears storage on logout or authentication failure

## Error Handling

All services use consistent error handling:
- 400: Bad request with validation details
- 401: Unauthorized (triggers automatic token refresh)
- 403: Forbidden access
- 404: Resource not found
- 409: Conflict (e.g., user already exists)
- 422: Validation error
- 500: Server error

## Security Features

- Tokens stored in secure storage (encrypted)
- Automatic token refresh on expiration
- Secure headers management
- Request/response logging (disable in production)

## Testing

To test the implementation:
1. Update the `baseUrl` in `api_constants.dart`
2. Ensure your backend is running
3. Use the example code above in your widgets or tests
