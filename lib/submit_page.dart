import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _githubController = TextEditingController(text: "https://github.com/anjeliadwichy/tugas_pbm_1.git");
  
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  final Color cardinal = const Color(0xFFAC1634);

  Future<void> _submitTugas() async {
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'auth_token');
    final url = Uri.parse('https://task.itprojects.web.id/api/products/submit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'description': _descController.text,
          'github_url': _githubController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submit tugas berhasil!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${response.body}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Tugas'), backgroundColor: cardinal, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Kirim produk final dan link GitHub", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Produk')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(controller: _githubController, decoration: const InputDecoration(labelText: 'Link GitHub')),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cardinal, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _submitTugas,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SUBMIT TUGAS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}