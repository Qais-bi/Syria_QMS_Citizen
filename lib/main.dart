import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SyriaDigitalApp());
}

class SyriaDigitalApp extends StatelessWidget {
  const SyriaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بوابة سوريا الرقمية',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto', // يمكنك تغييرها لاحقاً لخط عربي
      ),
      home: const CitizenHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String _selectedService = 'تجديد جواز سفر';
  String _qrData = '';

  // مفتاح التشفير (يجب أن يكون متطابقاً مع تطبيق الموظف)
  final key = encrypt.Key.fromUtf8('my_super_secret_key_32_chars_long');
  final iv = encrypt.IV.fromLength(16);

  void _generateSecureTicket() {
    if (_nameController.text.isEmpty || _idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء البيانات كاملة')),
      );
      return;
    }

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final plainText = 'Name: ${_nameController.text}, ID: ${_idController.text}, Service: $_selectedService';
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    setState(() {
      _qrData = encrypted.base64;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة المواطن السوري الرقمية 🇸🇾'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.account_balance, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'الرقم الوطني', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedService,
              items: ['تجديد جواز سفر', 'بيان عائلي', 'خلاصة سجل عدلي', 'تسجيل واقعة زواج']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedService = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _generateSecureTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('حجز دور وتوليد رمز QR', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  const Text('تذكرتك الرقمية المشفرة:', style: TextStyle(fontWeight: Colors.bold)),
                  const SizedBox(height: 10),
                  QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text('يرجى إبراز هذا الرمز للموظف المختص', style: TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
