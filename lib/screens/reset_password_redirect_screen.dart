import 'package:flutter/material.dart';

class ResetPasswordRedirectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF3F2),
      appBar: AppBar(
        title: Text("Redefinir Senha"),
        backgroundColor: Color(0xFFFE724C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 60, color: Color(0xFFFE724C)),
              SizedBox(height: 20),
              Text(
                'Verifique seu e-mail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF272D2F),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Enviamos um link para redefinir sua senha. Acesse seu e-mail e siga as instruções.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF444444)),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFE724C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
