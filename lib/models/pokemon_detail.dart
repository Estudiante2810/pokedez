class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final String spriteUrl;
  final List<String> moves;

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
    );
  }
}
