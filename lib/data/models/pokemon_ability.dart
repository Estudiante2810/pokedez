import 'package:hive/hive.dart';

part 'pokemon_ability.g.dart';

@HiveType(typeId: 2)
class PokemonAbility {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final bool isHidden;

  @HiveField(2)
  final String effect;

  PokemonAbility({
    required this.name,
    required this.isHidden,
    required this.effect,
  });

  factory PokemonAbility.fromGraphQL(Map<String, dynamic> json) {
    final name = (json['pokemon_v2_ability'] as Map<String, dynamic>)['name'] as String;
    final isHidden = json['is_hidden'] as bool? ?? false;
    
    // Parse effect text
    String effect = 'No hay descripción disponible';
    final abilityData = json['pokemon_v2_ability'] as Map<String, dynamic>?;
    if (abilityData != null) {
      final effectEntries = abilityData['pokemon_v2_abilityeffecttexts'] as List<dynamic>? ?? [];
      if (effectEntries.isNotEmpty) {
        final effectText = (effectEntries[0] as Map<String, dynamic>)['effect'] as String? ?? '';
        effect = effectText.isNotEmpty ? effectText : 'No hay descripción disponible';
      }
    }

    return PokemonAbility(
      name: name,
      isHidden: isHidden,
      effect: effect,
    );
  }
}
