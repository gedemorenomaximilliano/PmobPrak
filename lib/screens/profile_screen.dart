import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _profileError;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await apiService.getUserProfile();
      if (mounted) setState(() { _user = user; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _profileError = e.toString(); });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
      request.files.add(http.MultipartFile.fromBytes('profile_picture', bytes, filename: _image!.name));
      final response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        _loadProfile();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/user/profile'),
        headers: {
          'Authorization': 'Bearer ${apiService.getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        _loadProfile();
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ProfileEditPage(user: _user, onSave: (data) async {
        await _updateProfile(data);
        _loadProfile();
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), onPressed: _openEditPage),
        ],
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
            : _profileError != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        const Text('Failed to load profile', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () { setState(() { _isLoading = true; _profileError = null; }); _loadProfile(); },
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 40),
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _user?['name'] ?? 'User',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          _user?['email'] ?? '',
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildMenuTile(
                        Icons.receipt_long_rounded,
                        'Purchase History',
                        'View your bookings and tickets',
                        () => Navigator.pushNamed(context, '/transactions'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await apiService.logout();
                            if (!mounted) return;
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
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: Colors.white12,
              backgroundImage: _image != null
                  ? FileImage(File(_image!.path)) as ImageProvider
                  : (_user?['profile_picture'] != null
                      ? MemoryImage(apiService.base64ToBytes(
                          _user!['profile_picture'].toString().split(',').last))
                      : null),
              child: (_image == null && _user?['profile_picture'] == null)
                  ? const Icon(Icons.person, size: 64, color: Colors.white38)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF42A5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, 'Name', _user?['name'] ?? 'N/A'),
          _infoRow(Icons.email_outlined, 'Email', _user?['email'] ?? 'N/A'),
          _infoRow(Icons.phone_outlined, 'Phone', _user?['phone'] ?? 'N/A'),
          _infoRow(Icons.security_outlined, 'Role', _user?['role'] ?? 'User'),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: const Color(0xFF42A5F5), size: 22),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing:
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _ProfileEditPage({required this.user, required this.onSave});

  @override
  State<_ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<_ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.user?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Personal Information'),
            const SizedBox(height: 12),
            _buildField(controller: _nameController, icon: Icons.person_outline, hint: 'Full Name', keyboard: TextInputType.name),
            const SizedBox(height: 12),
            _buildField(controller: _phoneController, icon: Icons.phone_outlined, hint: 'Phone Number', keyboard: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15));
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboard,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: Center(child: Icon(icon, color: const Color(0xFF42A5F5).withOpacity(0.6), size: 18)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
