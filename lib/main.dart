import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';

import 'viewmodels/auth_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/movie_detail_view_model.dart';
import 'viewmodels/favourite_view_model.dart';

import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/search_screen.dart';
import 'views/movie_detail_screen.dart';
import 'views/favourite_screen.dart';

bool _isLoggedIn = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  _isLoggedIn = await AuthService().isLoggedIn(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => MovieDetailViewModel()),
        ChangeNotifierProvider(create: (_) => FavouriteViewModel())
      ],
      child: MaterialApp(
        title: 'CineScope Movie Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.black,
        ),
        
        initialRoute: _isLoggedIn ? '/' : LoginScreen.routeName, 

        routes: {
          '/': (ctx) => const HomeScreen(), 
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterScreen.routeName: (ctx) => const RegisterScreen(),
          SearchScreen.routeName: (ctx) => const SearchScreen(),
          MovieDetailScreen.routeName: (ctx) => const MovieDetailScreen(),
          FavouriteScreen.routeName: (ctx) => const FavouriteScreen(),
        },
      ),
    );
  }
}