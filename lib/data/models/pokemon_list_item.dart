class PokemonListItem {
  final String name;
  final int id;
  final String imageUrl;

  PokemonListItem({required this.name, required this.id, required this.imageUrl});

  /// Parse PokemonListItem from GraphQL response
  factory PokemonListItem.fromGraphQL(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;

    // Generar URL de imagen usando el ID (sprites de HOME - 256x256px)
    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png';

    return PokemonListItem(name: name, id: id, imageUrl: imageUrl);
  }
}
