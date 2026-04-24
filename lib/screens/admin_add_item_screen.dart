import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

class AdminAddItemScreen extends StatefulWidget {
  const AdminAddItemScreen({super.key});

  @override
  State<AdminAddItemScreen> createState() => _AdminAddItemScreenState();
}

class _AdminAddItemScreenState extends State<AdminAddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  XFile? _thumbnail;
  final List<XFile> _extraImages = [];
  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await apiService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading categories: $e')));
      }
    }
  }

  Future<void> _pickImage(bool isThumbnail) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isThumbnail) {
          _thumbnail = pickedFile;
        } else {
          _extraImages.add(pickedFile);
        }
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _thumbnail == null ||
        _selectedCategoryId == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Please fill all fields, select dates, and choose a thumbnail')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/items'));
      request.headers
          .addAll({'Authorization': 'Bearer ${apiService.getToken()}'});
      request.fields['category_id'] = _selectedCategoryId.toString();
      request.fields['name'] = _nameController.text;
      request.fields['location'] = _locationController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock'] = _stockController.text;
      request.fields['date_start'] = _startDate.toString().split(' ')[0];
      request.fields['date_end'] = _endDate.toString().split(' ')[0];

      // Add thumbnail
      final thumbnailBytes = await _thumbnail!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image_file',
        thumbnailBytes,
        filename: _thumbnail!.name,
      ));

      // Add extra images
      for (int i = 0; i < _extraImages.length; i++) {
        final imageBytes = await _extraImages[i].readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'extra_images[$i]',
          imageBytes,
          filename: _extraImages[i].name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) => value!.isEmpty ? 'Field required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: const Text('Add New Destination',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          dropdownColor: const Color(0xFF0D2B4E),
                          style: const TextStyle(color: Colors.white),
                          hint: const Text('Select Category',
                              style: TextStyle(color: Colors.white60)),
                          items: _categories
                              .map<DropdownMenuItem<int>>((c) =>
                                  DropdownMenuItem<int>(
                                      value: c['id'], child: Text(c['name'])))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategoryId = val),
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildField(_nameController, 'Name / Package'),
                      _buildField(_locationController, 'Location'),
                      _buildField(_descController, 'Description'),
                      _buildField(_priceController, 'Price', isNumber: true),
                      _buildField(_stockController, 'Stock', isNumber: true),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => _selectDate(true),
                                  child: Text(_startDate == null
                                      ? "Start Date"
                                      : "Start: ${_startDate.toString().split(' ')[0]}"))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => _selectDate(false),
                                  child: Text(_endDate == null
                                      ? "End Date"
                                      : "End: ${_endDate.toString().split(' ')[0]}"))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => _pickImage(true),
                                  child: Text(_thumbnail == null
                                      ? "Thumbnail"
                                      : "Thumbnail OK"))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => _pickImage(false),
                                  child:
                                      Text("Extra (${_extraImages.length})"))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      GradientButton('Save Destination', _submit),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
