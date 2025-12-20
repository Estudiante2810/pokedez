import 'package:hive/hive.dart';

part 'pokemon_evolution.g.dart';

@HiveType(typeId: 3)
class PokemonEvolution {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String triggerType; // 'level', 'item', 'trade', 'happiness', 'location', 'time-of-day', 'other'

  @HiveField(4)
  final String triggerDetails; // "Lv 16", "Piedra Fuego", etc.

  PokemonEvolution({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.triggerType,
    required this.triggerDetails,
  });

  factory PokemonEvolution.fromGraphQL(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png';

    String triggerType = 'other';
    String triggerDetails = 'Desconocido';

    // Parse evolution trigger details
    final evolutionDetails = json['pokemon_v2_pokemonevolutions'] as List<dynamic>? ?? [];
    if (evolutionDetails.isNotEmpty) {
      final evo = evolutionDetails[0] as Map<String, dynamic>;

      final trigger = evo['pokemon_v2_evolutiontrigger'] as Map<String, dynamic>?;
      if (trigger != null) {
        triggerType = trigger['name'] as String? ?? 'other';
      }

      // Build trigger details based on type
      switch (triggerType) {
        case 'level':
          final minLevel = evo['min_level'] as int?;
          if (minLevel != null) {
            triggerDetails = 'Nivel $minLevel';
          }
          break;
        case 'item':
          final item = evo['pokemon_v2_item'] as Map<String, dynamic>?;
          if (item != null) {
            triggerDetails = _capitalize(item['name'] as String? ?? 'Objeto desconocido');
          }
          break;
        case 'trade':
          triggerDetails = 'Intercambio';
          break;
        case 'happiness':
          triggerDetails = 'Gran amistad';
          break;
        case 'location':
          final location = evo['pokemon_v2_location'] as Map<String, dynamic>?;
          if (location != null) {
            triggerDetails =
                _capitalize(location['name'] as String? ?? 'Ubicación desconocida');
          }
          break;
        case 'time-of-day':
          final timeOfDay = evo['time_of_day'] as String? ?? '';
          triggerDetails = timeOfDay.isEmpty ? 'Hora específica' : _capitalize(timeOfDay);
          break;
        default:
          triggerDetails = 'Método especial';
      }
    }

    return PokemonEvolution(
      id: id,
      name: name,
      imageUrl: imageUrl,
      triggerType: triggerType,
      triggerDetails: triggerDetails,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
}
