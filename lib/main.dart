import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import 'screens/recipe_create_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_recipes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reset_password_redirect_screen.dart';

import 'services/auth_service.dart';
import 'providers/favorite_provider.dart';

// Criação manual do client global
const supabaseUrl = 'https://sizovghaygzecxbgvqvb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpem92Z2hheWd6ZWN4Ymd2cXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MDg2MTMsImV4cCI6MjA2NTE4NDYxM30.6etw0TwLyChIFDAIRWK0uhADrHNHn-qlYkFld9F5VVE';

final SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseKey);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider()..loadFavoritesFromBackend(),
        ),
      ],
      child: MyApp(isLoggedIn: token != null && token.isNotEmpty),
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
        primaryColor: Color(0xFFFE724C),
        scaffoldBackgroundColor: Color(0xFFF2F2F2),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF272D2F)),
        ),
      ),
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/create': (context) => RecipeCreateScreen(),
        '/my_recipes': (context) => MyRecipesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/reset': (context) => ResetPasswordRedirectScreen(),
      },
    );
  }
}
