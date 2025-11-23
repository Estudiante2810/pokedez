import 'package:hive/hive.dart';

part 'pokemon_detail.g.dart';

@HiveType(typeId: 1)
class PokemonDetail {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int height;

  @HiveField(3)
  final int weight;

  @HiveField(4)
  final List<String> types;

  @HiveField(5)
  final List<String> abilities;

  @HiveField(6)
  final Map<String, int> stats;

  @HiveField(7)
  final String spriteUrl;

  @HiveField(8)
  final List<String> moves;

  @HiveField(9)
  bool isFavorite = false; // Campo para marcar si el Pokémon es favorito

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.spriteUrl,
    required this.moves,
    this.isFavorite = false, // Inicializar como no favorito por defecto
  });

  /// Parse PokemonDetail from GraphQL response
  factory PokemonDetail.fromGraphQL(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final height = json['height'] as int;
    final weight = json['weight'] as int;

    // Parse types from GraphQL format
    final typesList = <String>[];
    final types = json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [];
    for (final t in types) {
      final typeName = (t as Map<String, dynamic>)['pokemon_v2_type']['name'] as String;
      typesList.add(typeName);
    }

    // Parse abilities from GraphQL format
    final abilitiesList = <String>[];
    final abilities = json['pokemon_v2_pokemonabilities'] as List<dynamic>? ?? [];
    for (final a in abilities) {
      final abilityName = (a as Map<String, dynamic>)['pokemon_v2_ability']['name'] as String;
      abilitiesList.add(abilityName);
    }

    // Parse stats from GraphQL format
    final statsMap = <String, int>{};
    final stats = json['pokemon_v2_pokemonstats'] as List<dynamic>? ?? [];
    for (final s in stats) {
      final m = s as Map<String, dynamic>;
      final statName = (m['pokemon_v2_stat'] as Map<String, dynamic>)['name'] as String;
      final value = m['base_stat'] as int;
      statsMap[statName] = value;
    }

    // Parse sprite from GraphQL format
    String sprite = '';
    try {
      final sprites = json['pokemon_v2_pokemonsprites'] as List<dynamic>? ?? [];
      if (sprites.isNotEmpty) {
        final spritesData = sprites[0] as Map<String, dynamic>;
        final spritesJson = spritesData['sprites'] as Map<String, dynamic>?;
        sprite = spritesJson?['other']['official-artwork']['front_default'] as String? ?? '';
        if (sprite.isEmpty) {
          sprite = spritesJson?['front_default'] as String? ?? '';
        }
      }
    } catch (_) {
      sprite = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png';
    }

    // Parse moves from GraphQL format
    final movesList = <String>[];
    final moves = json['pokemon_v2_pokemonmoves'] as List<dynamic>? ?? [];
    for (final m in moves) {
      final moveName = (m as Map<String, dynamic>)['pokemon_v2_move']['name'] as String;
      movesList.add(moveName);
    }

    return PokemonDetail(
      id: id,
      name: name,
      height: height,
      weight: weight,
      types: typesList,
      abilities: abilitiesList,
      stats: statsMap,
      spriteUrl: sprite,
      moves: movesList,
      isFavorite: (json['is_favorite'] as bool?) ?? false, // Manejo de nulos
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
