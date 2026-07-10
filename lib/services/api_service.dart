import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change to http://10.0.2.2:8000/api for Android emulator
  // Change to your PC's local IP for phone testing: http://YOUR_IP:8000/api
  static const String baseUrl = 'http://192.168.1.48:8000/api';
  static const String _tokenKey = 'auth_token';

  String? _authToken;
  int? _userId;
  late http.Client _client;

  int? get currentUserId => _userId;

  ApiService() {
    _client = http.Client();
  }

  // Load persisted token on app start
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  // Persist token to disk
  Future<void> saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  String? getToken() {
    return _authToken;
  }

  // Clear token from memory and disk
  Future<void> clearToken() async {
    _authToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_authToken != null) return true;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    return _authToken != null;
  }

  // HTTP request with timeout
  Future<http.Response> _get(Uri url, {Map<String, String>? headers}) {
    return _client.get(url, headers: headers).timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _post(Uri url, {Map<String, String>? headers, Object? body}) {
    return _client.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _delete(Uri url, {Map<String, String>? headers, Object? body}) {
    return _client.delete(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
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
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['access_token']);
      _userId = data['user']?['id'] ?? int.tryParse(data['id']?.toString() ?? '');
      return {...data, 'success': true, 'token': data['access_token']};
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  // Google Login
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await _post(
      Uri.parse('$baseUrl/login/google'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode({'id_token': idToken}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['access_token']);
      _userId = data['user']?['id'] ?? int.tryParse(data['id']?.toString() ?? '');
      return {...data, 'success': true, 'token': data['access_token']};
    }
    throw Exception(data['message'] ?? 'Google login failed');
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode(userData),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['access_token']);
      _userId = data['user']?['id'] ?? int.tryParse(data['id']?.toString() ?? '');
      return {...data, 'success': true, 'token': data['access_token']};
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  // Logout — call server and clear local token
  Future<void> logout() async {
    try {
      await _post(Uri.parse('$baseUrl/logout'), headers: _getHeaders());
    } catch (_) {
      // Server logout is best-effort; still clear local token
    }
    await clearToken();
  }

  // Get Categories
  Future<List<dynamic>> getCategories() async {
    final response = await _get(
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
    final response = await _get(
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
          'location': item['location'],
          'category': item['category'],
          'itinerary': item['itinerary'],
          'itinerary_items': item['itinerary_items'] ?? [],
        };
      }).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load items');
  }

  // Get Destination by ID
  Future<Map<String, dynamic>> getDestinationById(int id) async {
    final response = await _get(
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
        'itinerary': item['itinerary'],
        'itinerary_items': item['itinerary_items'] ?? [],
      };
    }
    throw Exception(data['message'] ?? 'Failed to load item');
  }

  // Create Item
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    final response = await _post(
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
    final response = await _post(
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

  // Midtrans Snap token
  Future<Map<String, dynamic>> createSnapToken(int orderId) async {
    final response = await _post(
      Uri.parse('$baseUrl/payment/snap-token'),
      headers: _getHeaders(),
      body: json.encode({'order_id': orderId}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to create snap token');
  }

  // Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus(int orderId) async {
    final response = await _get(
      Uri.parse('$baseUrl/transactions/$orderId'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to get transaction status');
  }

  // Get User Transactions
  Future<List<dynamic>> getUserTransactions() async {
    final response = await _get(
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
    final response = await _get(
      Uri.parse('$baseUrl/user'), // Ensure this endpoint exists in Laravel
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      _userId = data['user']?['id'] ?? data['id'] ?? int.tryParse(data['data']?['id']?.toString() ?? '');
      return data;
    }
    throw Exception('Failed to load profile');
  }

  // Favorite Methods
  Future<List<dynamic>> getFavorites() async {
    final response = await _get(Uri.parse('$baseUrl/favorites'), headers: _getHeaders());
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception('Failed to load favorites');
  }

  Future<void> toggleFavorite(int itemId, bool isFavorite) async {
    if (isFavorite) {
      await _delete(Uri.parse('$baseUrl/favorites/$itemId'), headers: _getHeaders());
    } else {
      await _post(Uri.parse('$baseUrl/favorites'), headers: _getHeaders(), body: json.encode({'item_id': itemId}));
    }
  }

  // Submit Rating
  Future<Map<String, dynamic>> submitRating(int itemId, int rating, String comment) async {
    final response = await _post(
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
    final response = await _delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to delete rating');
  }

  // Get Admin Dashboard Stats
  Future<Map<String, dynamic>> getAdminDashboard() async {
    final response = await _get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load dashboard');
  }

  // Delete Item
  Future<void> deleteItem(int itemId) async {
    final response = await _delete(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete item');
    }
  }
}

final apiService = ApiService();
