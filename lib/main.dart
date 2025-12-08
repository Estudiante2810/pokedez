import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screen/pokemon_list_screen.dart';
import 'presentation/screen/splash_screen.dart';
import 'data/datasources/poke_api.dart';
import 'presentation/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokedez/data/models/pokemon_detail.dart'; // Importa la clase y el adaptador


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Registra el adaptador para PokemonDetail
  Hive.registerAdapter(PokemonDetailAdapter());

  // Inicializa GraphQL
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