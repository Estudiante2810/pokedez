class PokemonListItem {
  final String name;
  final int id;
  final String imageUrl;

  PokemonListItem({required this.name, required this.id, required this.imageUrl});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final url = json['url'] as String; // ends with /<id>/
    final segments = url.split('/');
    int id = 0;
    if (segments.isNotEmpty) {
      // last non-empty segment should be the id
      for (var i = segments.length - 1; i >= 0; i--) {
        final s = segments[i];
        if (s.isNotEmpty) {
          id = int.tryParse(s) ?? 0;
          break;
        }
      }
    }

    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return PokemonListItem(name: name, id: id, imageUrl: imageUrl);
  }
}
