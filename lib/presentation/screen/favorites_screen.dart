import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/pokemon_detail.dart';
import 'pokemon_detail_screen.dart';
import 'pokemon_list_screen.dart';
import 'pokearth_map_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Box<PokemonDetail> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favoritesBox = await Hive.openBox<PokemonDetail>('favorites');
    setState(() {});
  }

  List<Map<String, dynamic>> getAllFavorites() {
    final data = _favoritesBox.keys.map((key) {
      final value = _favoritesBox.get(key);
      return {
        "key": key,
        "id": value?.id,
        "name": value?.name,
        "spriteUrl": value?.spriteUrl,
        "isFavorite": value?.isFavorite,
      };
    }).toList();

    return data.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Favoritos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: _favoritesBox.listenable(),
        builder: (context, Box<PokemonDetail> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No tienes Pokémon favoritos.'),
            );
          }

          final favorites = box.values.toList();

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final pokemon = favorites[index];
              return ListTile(
                leading: Image.network(
                  pokemon.spriteUrl,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.catching_pokemon),
                ),
                title: Text(pokemon.name),
                subtitle: Text('#${pokemon.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    box.delete(pokemon.id);
                  },
                ),
                onTap: () {
                  // Navegar a la pantalla de detalles del Pokémon
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(
                        id: pokemon.id,
                        name: pokemon.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Selecciona el índice de favoritos
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PokemonListScreen()),
            );
          } else if (index == 1) {
            // Ya estamos en favoritos, no hacer nada
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PokearthMapScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}