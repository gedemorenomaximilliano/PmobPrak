import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../widgets/gradient_button.dart';

class AdminEditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const AdminEditItemScreen({super.key, required this.item});

  @override
  State<AdminEditItemScreen> createState() => _AdminEditItemScreenState();
}

class _AdminEditItemScreenState extends State<AdminEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  DateTime? _startDate;
  DateTime? _endDate;

  XFile? _thumbnail;
  final List<XFile> _extraImages = [];
  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoading = false;
  bool _categoriesLoading = true;
  final List<_ItineraryEntry> _itineraryEntries = [];

  final Map<String, String?> _fieldErrors = {};
  String? _imageError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item['nama_destination'] ?? '');
    _locationController = TextEditingController(text: item['location'] ?? '');
    _descController = TextEditingController(text: item['deskripsi'] == 'null' ? '' : (item['deskripsi'] ?? ''));
    _priceController = TextEditingController(text: item['harga']?.toString() ?? '');
    _stockController = TextEditingController(text: item['stock']?.toString() ?? '');
    final existingItems = item['itinerary_items'] as List?;
    if (existingItems != null && existingItems.isNotEmpty) {
      for (final ii in existingItems) {
        _itineraryEntries.add(_ItineraryEntry(
          time: ii['time']?.toString() ?? '',
          activity: ii['activity']?.toString() ?? '',
        ));
      }
    }

    if (item['date_start'] != null && item['date_start'] != 'null') {
      try {
        _startDate = DateTime.parse(item['date_start'].toString());
      } catch (_) {}
    }
    if (item['date_end'] != null && item['date_end'] != 'null') {
      try {
        _endDate = DateTime.parse(item['date_end'].toString());
      } catch (_) {}
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    for (final e in _itineraryEntries) {
      e.timeController.dispose();
      e.activityController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await apiService.getCategories();
      final itemCategory = widget.item['category'];
      int? preselectedId;
      if (itemCategory != null) {
        preselectedId = itemCategory['id'];
      }
      setState(() {
        _categories = categories;
        _selectedCategoryId = preselectedId;
        _categoriesLoading = false;
      });
    } catch (e) {
      setState(() => _categoriesLoading = false);
      if (mounted) {
        _showError('Failed to load categories: $e');
      }
    }
  }

  void _showError(String message) {
    setState(() => _generalError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImage(bool isThumbnail) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024) {
          _showError('Image too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB). Max is 2MB.');
          return;
        }
        setState(() {
          _imageError = null;
          if (isThumbnail) {
            _thumbnail = pickedFile;
          } else {
            _extraImages.add(pickedFile);
          }
        });
        _showSuccess(isThumbnail ? 'Thumbnail selected' : 'Extra image added');
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
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

  int get _itemId => int.tryParse(widget.item['id_destination']?.toString() ?? '') ?? 0;

  Future<void> _submit() async {
    _fieldErrors.clear();
    setState(() {
      _imageError = null;
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the highlighted fields');
      return;
    }
    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/items/$_itemId'));
      request.headers.addAll({
        'Authorization': 'Bearer ${apiService.getToken()}',
        'X-HTTP-Method-Override': 'PUT',
      });
      request.fields['_method'] = 'PUT';
      request.fields['category_id'] = _selectedCategoryId.toString();
      request.fields['name'] = _nameController.text;
      request.fields['location'] = _locationController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock'] = _stockController.text;
      final itineraryJson = _itineraryEntries
          .where((e) => e.activityController.text.trim().isNotEmpty)
          .map((e) => {
                'time': e.timeController.text.trim(),
                'activity': e.activityController.text.trim(),
              })
          .toList();
      request.fields['itinerary_items'] = json.encode(itineraryJson);
      if (_startDate != null) {
        request.fields['date_start'] = _startDate.toString().split(' ')[0];
      }
      if (_endDate != null) {
        request.fields['date_end'] = _endDate.toString().split(' ')[0];
      }

      if (_thumbnail != null) {
        final thumbnailBytes = await _thumbnail!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image_file',
          thumbnailBytes,
          filename: _thumbnail!.name,
        ));
      }

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

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (!mounted) return;
        _showSuccess('Destination updated successfully');
        Navigator.pop(context, true);
      } else {
        String errorMsg = 'Server error ${response.statusCode}';
        try {
          final body = Map<String, dynamic>.from(
              Map<String, dynamic>.from(
                  (response.body.isNotEmpty) ? (response.body as dynamic) : {}));
          if (body['message'] != null) errorMsg = body['message'];
          if (body['errors'] != null) {
            final errors = body['errors'] as Map;
            errors.forEach((key, value) {
              final msg = (value is List) ? value.first.toString() : value.toString();
              if (key == 'image_file') {
                setState(() => _imageError = msg);
              } else {
                setState(() => _fieldErrors[key] = msg);
              }
            });
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool isNumber = false, String? fieldKey}) {
    final error = _fieldErrors[fieldKey ?? label.toLowerCase()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null
                  ? Colors.red.withOpacity(0.7)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: error != null ? Colors.red.shade300 : Colors.white60),
              prefixIcon: error != null
                  ? Icon(Icons.warning_amber_rounded, color: Colors.red.shade300, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            validator: (value) => value!.isEmpty ? 'Field required' : null,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(error, style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildItineraryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Itinerary Items',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 2),
              const Text('Add time & activity for each item',
                  style: TextStyle(color: Colors.white30, fontSize: 11)),
              const SizedBox(height: 12),
              ..._itineraryEntries.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: e.timeController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: '08.00',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white10,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: e.activityController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Activity description',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white10,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            e.timeController.dispose();
                            e.activityController.dispose();
                            _itineraryEntries.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              if (_itineraryEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('No items added yet',
                      style: TextStyle(color: Colors.white24, fontSize: 13)),
                ),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _itineraryEntries.add(_ItineraryEntry());
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.amber, size: 18),
                  label: const Text('Add Item',
                      style: TextStyle(color: Colors.amber, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final hasExistingImage = widget.item['gambar'] != null &&
        widget.item['gambar'].toString().startsWith('data:image');
    final hasNewThumbnail = _thumbnail != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildImagePickerButton(
                label: _thumbnail == null ? 'Change Thumbnail' : 'Thumbnail Selected',
                icon: Icons.camera_alt,
                isSelected: _thumbnail != null,
                hasExisting: hasExistingImage,
                onTap: () => _pickImage(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildImagePickerButton(
                label: 'Extra (${_extraImages.length})',
                icon: Icons.add_photo_alternate,
                isSelected: _extraImages.isNotEmpty,
                hasExisting: false,
                onTap: () => _pickImage(false),
              ),
            ),
          ],
        ),
        if (_imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_imageError!,
                      style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
                ),
              ],
            ),
          ),
        if (hasExistingThumbnail || _thumbnail != null) ...[
          const SizedBox(height: 12),
          _buildImagePreview(),
        ],
      ],
    );
  }

  bool get hasExistingThumbnail =>
      widget.item['gambar'] != null &&
      widget.item['gambar'].toString().startsWith('data:image');

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 160,
        width: double.infinity,
        color: Colors.white.withOpacity(0.05),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_thumbnail != null)
              Image.file(File(_thumbnail!.path), fit: BoxFit.cover)
            else if (hasExistingThumbnail)
              Image.memory(
                apiService.base64ToBytes(
                    widget.item['gambar'].toString().split(',').last),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
                ),
              )
            else
              const Center(
                child: Icon(Icons.image, color: Colors.white38, size: 40),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _thumbnail != null
                      ? Colors.green.withOpacity(0.8)
                      : Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _thumbnail != null ? 'New Image' : 'Current',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool hasExisting,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.15)
              : hasExisting
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.green.withOpacity(0.5)
                : hasExisting
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? Colors.green
                    : hasExisting
                        ? Colors.blue.shade300
                        : Colors.white54,
                size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.green
                      : hasExisting
                          ? Colors.blue.shade300
                          : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )),
            if (hasExisting && !isSelected)
              const Text('(has image)',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: const Text('Edit Destination',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)),
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
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Uploading...', style: TextStyle(color: Colors.white70)),
                ],
              ))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_generalError != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade300, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_generalError!,
                                    style: TextStyle(color: Colors.red.shade200, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      if (_categoriesLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedCategoryId == null && _generalError != null
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                            ),
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
                                        value: c['id'],
                                        child: Text(c['name'])))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCategoryId = val),
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildField(_nameController, 'Name / Package', fieldKey: 'name'),
                      _buildField(_locationController, 'Location', fieldKey: 'location'),
                      _buildField(_descController, 'Description', fieldKey: 'description'),
                      _buildField(_priceController, 'Price',
                          isNumber: true, fieldKey: 'price'),
                      _buildField(_stockController, 'Stock',
                          isNumber: true, fieldKey: 'stock'),
                      const SizedBox(height: 12),
                      _buildItineraryField(),
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
                      _buildImageSection(),
                      const SizedBox(height: 32),
                      GradientButton('Update Destination', _submit),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ItineraryEntry {
  final TextEditingController timeController;
  final TextEditingController activityController;

  _ItineraryEntry({String time = '', String activity = ''})
      : timeController = TextEditingController(text: time),
        activityController = TextEditingController(text: activity);
}
