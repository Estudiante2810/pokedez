import 'package:hive/hive.dart';

part 'pokemon_list_item.g.dart';

@HiveType(typeId: 0) // Define un ID único para este modelo
class PokemonListItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int id;

  @HiveField(2)
  final String imageUrl;

  PokemonListItem({
    required this.name,
    required this.id,
    required this.imageUrl,
  });

  factory PokemonListItem.fromGraphQL(Map<String, dynamic> data) {
    return PokemonListItem(
      name: data['name'] as String,
      id: data['id'] as int,
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/${data['id']}.png',
    );
  }
}
