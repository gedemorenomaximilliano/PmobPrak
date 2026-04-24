import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import 'transaction_complete_screen.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic destination;
  const PaymentScreen({super.key, required this.destination});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _pax = 1;
  int _selectedPay = 0;
  bool _isLoading = false;

  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _ewalletPhoneController = TextEditingController();
  final TextEditingController _qrisCodeController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _parsePrice(dynamic harga) {
    if (harga == null) return 0;

    try {
      String priceStr = harga.toString();

      // Remove decimal part (.00)
      if (priceStr.contains('.')) {
        priceStr = priceStr.substring(0, priceStr.indexOf('.'));
      }

      // Remove any non-numeric characters
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');

      if (priceStr.isEmpty) return 0;

      return int.parse(priceStr);
    } catch (e) {
      return 0;
    }
  }

  int get _basePrice => _parsePrice(widget.destination['harga']);

  int get _totalPrice => _basePrice * _pax;

  String _formatIDR(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'IDR ${buf.toString()}';
  }

  final List<_PayMethod> _methods = const [
    _PayMethod(
        label: 'Bank Transfer',
        icon: FontAwesomeIcons.buildingColumns,
        color: Color(0xFF1565C0)),
    _PayMethod(
        label: 'Credit Card',
        icon: FontAwesomeIcons.creditCard,
        color: Color(0xFF6A1B9A)),
    _PayMethod(
        label: 'E-Wallet',
        icon: FontAwesomeIcons.wallet,
        color: Color(0xFF00695C)),
    _PayMethod(
        label: 'QRIS', icon: FontAwesomeIcons.qrcode, color: Color(0xFFE65100)),
  ];

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
    double width = 50,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: width,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Center(child: FaIcon(icon, color: color, size: 18)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              obscureText: obscure,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF42A5F5).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF42A5F5).withOpacity(0.3), width: 1.5),
        ),
        child: Center(
            child: FaIcon(icon, color: const Color(0xFF42A5F5), size: 18)),
      ),
    );
  }

  Widget _buildContactField({
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Center(child: FaIcon(icon, color: color, size: 18)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodFields() {
    switch (_selectedPay) {
      case 0:
        return Column(children: [
          const SizedBox(height: 16),
          _detailCard('Bank Transfer Details', [
            _buildStyledTextField(
                controller: _bankAccountController,
                icon: FontAwesomeIcons.buildingColumns,
                color: const Color(0xFF1565C0),
                hint: 'Account Number'),
            const SizedBox(height: 10),
            _buildStyledTextField(
                controller: _bankNameController,
                icon: FontAwesomeIcons.house,
                color: const Color(0xFF1565C0),
                hint: 'Bank Name'),
          ]),
        ]);
      case 1:
        return Column(children: [
          const SizedBox(height: 16),
          _detailCard('Credit Card Details', [
            _buildStyledTextField(
                controller: _cardNumberController,
                icon: FontAwesomeIcons.creditCard,
                color: const Color(0xFF6A1B9A),
                hint: 'Card Number'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _buildStyledTextField(
                      controller: _cardExpiryController,
                      icon: FontAwesomeIcons.calendar,
                      color: const Color(0xFF6A1B9A),
                      hint: 'MM/YY',
                      width: 40)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStyledTextField(
                      controller: _cardCvvController,
                      icon: FontAwesomeIcons.lock,
                      color: const Color(0xFF6A1B9A),
                      hint: 'CVV',
                      obscure: true,
                      width: 40)),
            ]),
          ]),
        ]);
      case 2:
        return Column(children: [
          const SizedBox(height: 16),
          _detailCard('E-Wallet Details', [
            _buildStyledTextField(
                controller: _ewalletPhoneController,
                icon: FontAwesomeIcons.wallet,
                color: const Color(0xFF00695C),
                hint: 'Phone Number',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _ewalletBtn(FontAwesomeIcons.googlePay, 'Google Pay')),
              const SizedBox(width: 10),
              Expanded(
                  child: _ewalletBtn(FontAwesomeIcons.applePay, 'Apple Pay')),
            ]),
          ]),
        ]);
      case 3:
        return Column(children: [
          const SizedBox(height: 16),
          _detailCard('Scan QRIS Code', [
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Center(
                    child: FaIcon(FontAwesomeIcons.qrcode,
                        color: Colors.black, size: 120)),
              ),
            ),
            const SizedBox(height: 20),
            _buildStyledTextField(
                controller: _qrisCodeController,
                icon: FontAwesomeIcons.pen,
                color: const Color(0xFFE65100),
                hint: 'Enter QRIS code'),
          ]),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _detailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _ewalletBtn(IconData icon, String label) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _isLoading = true);

    try {
      final orderData = {
        'id_schedule': 1,
        'jumlah_orang': _pax,
        'total_price': _totalPrice + (_totalPrice * 0.11).round(),
        'id_package': null,
      };

      final orderResult = await apiService.createOrder(orderData);

      if (orderResult['success']) {
        final paymentData = {
          'id_order': orderResult['orderId'],
          'metode_pembayaran': _methods[_selectedPay].label,
          'total_bayar': _totalPrice + (_totalPrice * 0.11).round(),
        };

        await apiService.createPayment(paymentData);

        if (!mounted) return;
        setState(() => _isLoading = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionCompleteScreen(
              destination: widget.destination,
              pax: _pax,
              total: _totalPrice + (_totalPrice * 0.11).round(),
              payMethod: _methods[_selectedPay].label,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            stops: [0.0, 0.30, 0.65],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDestinationSummary(),
                      const SizedBox(height: 20),
                      _buildPaxSelector(),
                      const SizedBox(height: 20),
                      _buildPaymentMethods(),
                      _buildPaymentMethodFields(),
                      const SizedBox(height: 20),
                      _buildContactFields(),
                      const SizedBox(height: 20),
                      _buildOrderSummary(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Booking & Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDestinationSummary() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: _buildDestinationImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.destination['nama_destination'] ?? 'Unknown',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Row(children: [
                  const FaIcon(FontAwesomeIcons.solidStar,
                      color: Color(0xFFFFA000), size: 14),
                  const SizedBox(width: 4),
                  Text(
                      '${widget.destination['rating']?.toString() ?? '0.0'} (${widget.destination['review'] ?? 0} reviews)',
                      style: const TextStyle(
                          color: Color(0xFFFFA000), fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Text(
                  widget.destination['deskripsi'] == 'null' ||
                          widget.destination['deskripsi'] == null
                      ? 'No description available'
                      : widget.destination['deskripsi'],
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationImage() {
    final gambar = widget.destination['gambar'];
    if (gambar != null && gambar.toString().startsWith('data:image')) {
      try {
        final base64String = gambar.toString().split(',').last;
        final bytes = apiService.base64ToBytes(base64String);
        return Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderImage(),
        );
      } catch (e) {
        return _placeholderImage();
      }
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      color: const Color(0xFF2C3E50),
      child: const Center(
          child:
              FaIcon(FontAwesomeIcons.image, color: Colors.white54, size: 60)),
    );
  }

  Widget _buildPaxSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Number of Visitors'),
          const SizedBox(height: 16),
          Row(children: [
            _buildCounterButton(FontAwesomeIcons.minus, () {
              if (_pax > 1) setState(() => _pax--);
            }),
            const SizedBox(width: 16),
            Text('$_pax',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 16),
            _buildCounterButton(FontAwesomeIcons.plus, () {
              if (_pax < 20) setState(() => _pax++);
            }),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatIDR(_basePrice),
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 2),
                Text(_formatIDR(_totalPrice),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Payment Method'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: _methods.length,
            itemBuilder: (_, i) {
              final selected = i == _selectedPay;
              return GestureDetector(
                onTap: () => setState(() => _selectedPay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? _methods[i].color.withOpacity(0.2)
                        : const Color(0xFF0D1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? _methods[i].color
                          : Colors.white.withOpacity(0.1),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: selected
                            ? BoxDecoration(
                                color: _methods[i].color.withOpacity(0.3),
                                shape: BoxShape.circle)
                            : null,
                        child: Center(
                            child: FaIcon(_methods[i].icon,
                                color: selected
                                    ? _methods[i].color
                                    : Colors.white38,
                                size: 16)),
                      ),
                      const SizedBox(width: 8),
                      Text(_methods[i].label,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactFields() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Contact Details'),
          const SizedBox(height: 16),
          _buildContactField(
              icon: FontAwesomeIcons.user,
              color: const Color(0xFF42A5F5),
              hint: 'Full Name',
              controller: _fullNameController),
          const SizedBox(height: 12),
          _buildContactField(
              icon: FontAwesomeIcons.envelope,
              color: const Color(0xFF42A5F5),
              hint: 'Email Address',
              controller: _emailController),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final tax = (_totalPrice * 0.11).round();
    final grandTotal = _totalPrice + tax;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Order Summary'),
          const SizedBox(height: 12),
          _summaryRow(
              '${widget.destination['nama_destination'] ?? 'Destination'} × $_pax pax',
              _formatIDR(_totalPrice)),
          _summaryRow('Tax (11%)', _formatIDR(tax)),
          const Divider(color: Colors.white12, height: 24),
          _summaryRow('Total', _formatIDR(grandTotal),
              bold: true, accent: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, bool accent = false}) {
    final style = TextStyle(
      color: accent ? const Color(0xFF42A5F5) : Colors.white60,
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _buildPayButton() {
    final tax = (_totalPrice * 0.11).round();
    final grandTotal = _totalPrice + tax;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: const Color(0xFF0A1A2B),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GradientButton('Pay ${_formatIDR(grandTotal)}', _pay,
              height: 56, radius: 16),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14));
  }
}

class _PayMethod {
  final String label;
  final IconData icon;
  final Color color;
  const _PayMethod(
      {required this.label, required this.icon, required this.color});
}
