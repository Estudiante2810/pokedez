import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screen/pokemon_list_screen.dart';
import 'presentation/screen/splash_screen.dart';
import 'data/datasources/poke_api.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  PokeApi.initGraphQL();
  runApp(const ProviderScope(child: MyApp()));
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