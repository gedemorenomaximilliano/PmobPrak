import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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
      'Authorization': _authToken != null ? 'Bearer $_authToken' : '',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      saveToken(data['token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 && data['success']) {
      saveToken(data['token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  // Get destinations
  Future<List<dynamic>> getDestinations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load destinations');
  }

  // Get popular destinations
  Future<List<dynamic>> getPopularDestinations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations/popular'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load popular destinations');
  }

  // Get destination by ID
  Future<Map<String, dynamic>> getDestinationById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations/$id'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load destination');
  }

  // Get schedules for destination
  Future<List<dynamic>> getSchedules(int destinationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations/$destinationId/schedules'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load schedules');
  }

  // Create order
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(),
      body: json.encode(orderData),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 && data['success']) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to create order');
  }

  // Get user orders
  Future<List<dynamic>> getUserOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load orders');
  }

  // Create payment
  Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: _getHeaders(),
      body: json.encode(paymentData),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 && data['success']) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to create payment');
  }

  // Get payment by order ID
  Future<Map<String, dynamic>> getPaymentByOrder(int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/order/$orderId'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to load payment');
  }
}

final apiService = ApiService();
