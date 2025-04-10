import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = await AuthService().isLoggedIn(); // Verifica se o usuário está logado
  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CookTogether',
      theme: ThemeData(
        primaryColor: Color(0xFFFE724C), // Cor principal do app
        scaffoldBackgroundColor: Color(0xFFF2F2F2), // Fundo do app
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF272D2F)), // Cor do texto
        ),
      ),
      home: HomeScreen(), // Define WelcomeScreen como primeira tela
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
