import 'dart:convert';
import 'dart:io' as io if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await apiService.getUserProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = pickedFile);
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_image == null) return;
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/user/profile'));
      request.headers.addAll({'Authorization': 'Bearer ${apiService.getToken()}'});
      
      final bytes = await _image!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'profile_picture', 
        bytes,
        filename: _image!.name
      ));
      
      final response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        _loadProfile();
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  Future<void> _updateProfileData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/user/profile'),
        headers: {
          'Authorization': 'Bearer ${apiService.getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'payment_info': _paymentController.text,
        }),
      );
      if (response.statusCode == 200) {
        _loadProfile();
      } else {
        throw Exception('Update failed: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditDialog() {
    _nameController.text = _user?['name'] ?? '';
    _phoneController.text = _user?['phone'] ?? '';
    _paymentController.text = _user?['payment_info'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: _paymentController, decoration: const InputDecoration(labelText: 'Payment Info')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { _updateProfileData(); Navigator.pop(context); }, child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog)],
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView(
                padding: const EdgeInsets.only(top: 120, left: 24, right: 24),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        backgroundImage: _image != null
                            ? (kIsWeb ? NetworkImage(_image!.path) : FileImage(io.File(_image!.path))) as ImageProvider
                            : (_user?['profile_picture'] != null
                                ? MemoryImage(apiService.base64ToBytes(_user!['profile_picture'].toString().split(',').last))
                                : null),
                        child: _image == null && _user?['profile_picture'] == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoTile('Name', _user?['name'] ?? 'N/A', Icons.person_outline),
                  _buildInfoTile('Email', _user?['email'] ?? 'N/A', Icons.email_outlined),
                  _buildInfoTile('Phone', _user?['phone'] ?? 'N/A', Icons.phone_outlined),
                  _buildInfoTile('Payment', _user?['payment_info'] ?? 'N/A', Icons.payment_outlined),
                  _buildInfoTile('Role', _user?['role'] ?? 'User', Icons.security_outlined),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      apiService.clearToken();
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }


  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
