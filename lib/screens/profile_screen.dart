import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'welcome_screen.dart'; // 👈 novo import

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final Color appColor = Color(0xFFFE724C);
  final Color textColor = Color(0xFF272D2F);

  bool _loading = false;
  String _message = '';

  final String baseUrl = 'https://tcc-ulbra-2025-backend.onrender.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await AuthService().getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/edit/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _nameController.text = data['nickname'] ?? '';
        _emailController.text = data['email'] ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _loading = false;
        _message = 'As senhas não coincidem';
      });
      return;
    }

    final token = await AuthService().getToken();
    if (token == null) return;

    final body = {
      'nickname': _nameController.text,
      'email': _emailController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      body['password'] = _passwordController.text;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/users/edit/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      setState(() => _message = 'Alterações salvas com sucesso.');
    } else {
      setState(() => _message = 'Erro ao salvar alterações.');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()), // 👈 redireciona para Welcome
        (route) => false,
      );
    }
  }

  Future<void> _deactivateAccount() async {
    final token = await AuthService().getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/deactivate/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      await _logout();
    } else {
      setState(() => _message = 'Erro ao desativar a conta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: appColor,
        title: Text('Perfil', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Nova senha'),
              obscureText: true,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar nova senha'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Salvar Alterações', style: TextStyle(color: textColor)),
            ),
            SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(_message, style: TextStyle(color: appColor)),
            SizedBox(height: 40),
            TextButton(
              onPressed: _deactivateAccount,
              child: Text(
                'Excluir minha conta',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
