import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screen/splash_screen.dart';
import 'data/datasources/poke_api.dart';
import 'presentation/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokedez/data/models/pokemon_detail.dart';
import 'package:pokedez/data/models/pokemon_ability.dart';
import 'package:pokedez/data/models/pokemon_evolution.dart';
import 'package:pokedez/data/models/pokemon_move.dart';
import 'presentation/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();
  // Registra los adaptadores
  Hive.registerAdapter(PokemonDetailAdapter());
  Hive.registerAdapter(PokemonAbilityAdapter());
  Hive.registerAdapter(PokemonEvolutionAdapter());
  Hive.registerAdapter(PokemonMoveAdapter());
  await Hive.openBox<PokemonDetail>('favorites');

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
        child: HomeScreen(),
      ),
    );
  }
}