import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  // Use http://10.0.2.2:8000 for Android emulator
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  String? _authToken;

  // Store token in memory
  void saveToken(String token) {
    _authToken = token;
  }

  // Get token
  String? getToken() {
    return _authToken;
  }

  // Clear token
  void clearToken() {
    _authToken = null;
  }

  // Helper to convert base64 to bytes
  Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  // Headers with auth
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      saveToken(data['access_token']);
      return {...data, 'success': true, 'token': data['access_token']};
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode(userData),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      saveToken(data['access_token']);
      return {...data, 'success': true, 'token': data['access_token']};
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  // Get Categories
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load categories');
  }

  // Legacy name support for home_screen.dart
  Future<List<dynamic>> getDestinations() => getItems();
  Future<List<dynamic>> getPopularDestinations() => getItems(); // For now same as all items

  // Get Items
  Future<List<dynamic>> getItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/items'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      // Mapping Laravel 'items' to 'destinations' structure for UI compatibility
      return (data['data'] as List).map((item) {
        return {
          'id_destination': item['id'],
          'nama_destination': item['name'],
          'deskripsi': item['description'],
          'harga': item['price'],
          'gambar': item['image'],
          'rating': item['rating'],
          'stock': item['stock'],
          'date_start': item['date_start'],
          'date_end': item['date_end'],
          'images': item['images'] ?? [],
        };
      }).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load items');
  }

  // Get Destination by ID
  Future<Map<String, dynamic>> getDestinationById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/$id'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      final item = data['data'];
      return {
        'id_destination': item['id'],
        'nama_destination': item['name'],
        'deskripsi': item['description'],
        'harga': item['price'],
        'gambar': item['image'],
        'rating': item['rating'],
        'stock': item['stock'],
        'ratings': item['ratings'] ?? [],
        'images': item['images'] ?? [],
        'category': item['category'],
        'location': item['location'],
        'date_start': item['date_start'],
        'date_end': item['date_end'],
      };
    }
    throw Exception(data['message'] ?? 'Failed to load item');
  }

  // Create Item
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: _getHeaders(),
      body: json.encode(itemData),
    );

    final data = json.decode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) && data['success']) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to create item');
  }

  // Legacy name support
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    // Map Flutter order structure to Laravel transaction structure
    final transactionData = {
      'items': [
        {
          'id': orderData['id_destination'] ?? 1, // Fallback if not provided
          'quantity': orderData['jumlah_orang'] ?? 1,
        }
      ]
    };
    final res = await createTransaction(transactionData);
    return {
      'success': true,
      'orderId': res['data']['id'],
    };
  }

  // Create Transaction
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> transactionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _getHeaders(),
      body: json.encode(transactionData),
    );

    final data = json.decode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) && data['success']) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to create transaction');
  }

  // Placeholder for payment verification
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    // In a real app, this would hit a /payments endpoint. 
    // For now we'll simulate success since the migration for payments isn't explicitly in the user's Laravel guide yet.
    return {'success': true, 'message': 'Payment successful'};
  }

  // Get User Transactions
  Future<List<dynamic>> getUserTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load transactions');
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'), // Ensure this endpoint exists in Laravel
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception('Failed to load profile');
  }

  // Favorite Methods
  Future<List<dynamic>> getFavorites() async {
    final response = await http.get(Uri.parse('$baseUrl/favorites'), headers: _getHeaders());
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception('Failed to load favorites');
  }

  Future<void> toggleFavorite(int itemId, bool isFavorite) async {
    final method = isFavorite ? http.delete : http.post;
    final uri = isFavorite ? Uri.parse('$baseUrl/favorites/$itemId') : Uri.parse('$baseUrl/favorites');
    final body = isFavorite ? null : json.encode({'item_id': itemId});
    
    await method(uri, headers: _getHeaders(), body: body);
  }

  // OTP Verification Simulation
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    // Simulation
    if (otp == "123456") {
      return {'success': true};
    }
    throw Exception('Invalid OTP');
  }
  // Submit Rating
  Future<Map<String, dynamic>> submitRating(int itemId, int rating, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: _getHeaders(),
      body: json.encode({'item_id': itemId, 'rating': rating, 'comment': comment}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to submit rating');
  }
  // Delete Rating
  Future<Map<String, dynamic>> deleteRating(int ratingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to delete rating');
  }
}

final apiService = ApiService();
