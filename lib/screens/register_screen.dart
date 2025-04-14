import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool acceptedTerms = false;

  void register() async {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você precisa aceitar os termos para continuar.')),
      );
      return;
    }

    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await AuthService().register(email, password, username);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar. Tente novamente.')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD7463),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Registre-se',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF2F2F2),
                  ),
                ),
                SizedBox(height: 30),
                _buildTextField('Nome de usuário', usernameController),
                SizedBox(height: 15),
                _buildTextField('Email', emailController),
                SizedBox(height: 15),
                _buildTextField('Senha', passwordController, isPassword: true),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: acceptedTerms,
                      activeColor: Color(0xFF7F1D1D),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          acceptedTerms = value!;
                        });
                      },
                    ),
                    Flexible(
                      child: Text(
                        'Aceito a Política de Privacidade e os Termos de Uso',
                        style: TextStyle(color: Color(0xFFF2F2F2)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator(color: Color(0xFFF2F2F2))
                    : ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF2F2F2),
                          foregroundColor: Color(0xFF7F1D1D),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Criar conta', style: TextStyle(fontSize: 18)),
                      ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Ou continue com", style: TextStyle(color: Color(0xFFF2F2F2))),
                    ),
                    Expanded(child: Divider(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon('assets/icons/google.png'),
                    SizedBox(width: 15),
                    _buildSocialIcon('assets/icons/apple.png'),
                    SizedBox(width: 15),
                    _buildSocialIcon('assets/icons/facebook.png'),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Já tem conta? ',
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Faça login',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Color(0xFF7F1D1D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7F1D1D)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String path) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 22,
      child: Image.asset(path, width: 22),
    );
  }
}
