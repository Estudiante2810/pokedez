class PokemonEncounter {
  final int id;
  final String name;
  final String imageUrl;
  final int chance; // Probabilidad de aparición (0-100)
  final int minLevel; // Nivel mínimo
  final int maxLevel; // Nivel máximo
  final String method; // Método de encuentro (walking, fishing, etc.)
  final String version; // Versión del juego

  PokemonEncounter({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.chance,
    required this.minLevel,
    required this.maxLevel,
    required this.method,
    required this.version,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonEncounter &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          chance == other.chance &&
          minLevel == other.minLevel &&
          maxLevel == other.maxLevel &&
          method == other.method &&
          version == other.version;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      chance.hashCode ^
      minLevel.hashCode ^
      maxLevel.hashCode ^
      method.hashCode ^
      version.hashCode;
}
