import 'package:flutter/material.dart';
import 'screens/pokemon_list_screen.dart';
import 'screens/splash_screen.dart';
import 'services/poke_api.dart';
import 'theme/app_theme.dart';

void main() {
  PokeApi.initGraphQL();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(
        child: PokemonListScreen(),
      ),
    );
  }
}