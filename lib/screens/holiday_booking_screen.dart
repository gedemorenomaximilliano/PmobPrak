import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_button.dart';

class HolidayBookingScreen extends StatefulWidget {
  final dynamic destination;
  const HolidayBookingScreen({super.key, required this.destination});

  @override
  State<HolidayBookingScreen> createState() => _HolidayBookingScreenState();
}

class _HolidayBookingScreenState extends State<HolidayBookingScreen> {
  DateTime? _date;
  int _pax = 1;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await apiService.createTransaction({
        'items': [{'id': widget.destination['id_destination'], 'quantity': _pax}],
        'holiday_date': _date.toString().split(' ')[0],
        'pax_count': _pax
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking successful!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Holiday')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListTile(
              title: Text(_date == null ? 'Select Holiday Date' : 'Date: ${_date.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Amount of people: '),
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _pax = _pax > 1 ? _pax - 1 : 1)),
                Text('$_pax'),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _pax++)),
              ],
            ),
            const Spacer(),
            _isLoading ? const CircularProgressIndicator() : GradientButton('Confirm Booking', _submit),
          ],
        ),
      ),
    );
  }
}
