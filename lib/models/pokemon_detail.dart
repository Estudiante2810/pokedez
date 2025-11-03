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

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final height = json['height'] as int;
    final weight = json['weight'] as int;

    final typesList = (json['types'] as List<dynamic>)
        .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
        .toList();

    final abilitiesList = (json['abilities'] as List<dynamic>)
        .map((a) => (a as Map<String, dynamic>)['ability']['name'] as String)
        .toList();

    final statsMap = <String, int>{};
    for (final s in (json['stats'] as List<dynamic>)) {
      final m = s as Map<String, dynamic>;
      final name = (m['stat'] as Map<String, dynamic>)['name'] as String;
      final value = m['base_stat'] as int;
      statsMap[name] = value;
    }

    // preferred sprite if available
    String sprite = '';
    try {
      sprite = (json['sprites'] as Map<String, dynamic>)['other']['official-artwork']['front_default'] as String? ?? '';
    } catch (_) {
      sprite = (json['sprites'] as Map<String, dynamic>)['front_default'] as String? ?? '';
    }

    // moves (take as list of names)
    final movesList = (json['moves'] as List<dynamic>)
        .map((m) => (m as Map<String, dynamic>)['move']['name'] as String)
        .toList();

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
