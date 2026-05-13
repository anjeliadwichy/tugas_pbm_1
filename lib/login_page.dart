import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'catalog_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  final Color rusticRed = const Color(0xFF3E0014);
  final Color tyrianPurple = const Color(0xFF5B002C);
  final Color burgundy = const Color(0xFF7A002B);
  final Color cardinal = const Color(0xFFAC1634);
  final Color deepBlush = const Color(0xFFE77291);

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final nim = _nimController.text;
    final password = _passwordController.text;
    final url = Uri.parse('https://task.itprojects.web.id/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': nim,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['data']['token'];
        
        await _storage.write(key: 'auth_token', value: token);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login berhasil! Yeay SLAMATTT! 🎉'), 
              backgroundColor: burgundy,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CatalogPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Huhuhuuu😭, Login Gagal: ${response.body}'), 
              backgroundColor: rusticRed, 
            ),
          );
        }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error jaringan: $e'), backgroundColor: rusticRed),
          );
        }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF4F6), 
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_florist,
                  size: 90,
                  color: cardinal,
                ),
                const SizedBox(height: 16),
                Text(
                  'SELAMAT DATANG',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: rusticRed,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login terlebih dahulu yaaa! 😊',
                  style: TextStyle(
                    fontSize: 14,
                    color: tyrianPurple,
                  ),
                ),
                const SizedBox(height: 36),
                
                Card(
                  elevation: 2,
                  shadowColor: deepBlush.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nimController,
                          style: TextStyle(color: rusticRed),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: tyrianPurple),
                            prefixIcon: Icon(Icons.person, color: burgundy),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: deepBlush.withValues(alpha: 0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cardinal, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: rusticRed),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: tyrianPurple),
                            prefixIcon: Icon(Icons.lock, color: burgundy),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: deepBlush.withValues(alpha: 0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cardinal, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cardinal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}