import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/recipe_create_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/my_recipes_screen.dart';
import 'providers/favorite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = await AuthService().isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MyApp(isLoggedIn: loggedIn),
    ),
  );
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
        primaryColor: const Color(0xFFFE724C),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF272D2F)),
        ),
      ),
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/create': (context) => RecipeCreateScreen(),
        '/my_recipes': (context) => MyRecipesScreen(),
      },
    );
  }
}
