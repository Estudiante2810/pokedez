import 'package:hive/hive.dart';

part 'pokemon_move.g.dart';

@HiveType(typeId: 4)
class PokemonMove {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String method; // 'level-up', 'machine', 'tutor', 'egg'

  @HiveField(2)
  final int? level; // null para TM, Tutor, Egg

  @HiveField(3)
  final String versionGroup; // ej: 'scarlet-violet', 'sword-shield'

  PokemonMove({
    required this.name,
    required this.method,
    this.level,
    required this.versionGroup,
  });

  factory PokemonMove.fromGraphQL(Map<String, dynamic> json) {
    final name = (json['pokemon_v2_move'] as Map<String, dynamic>)['name'] as String;
    
    final level = json['level'] as int?;
    
    // Deduce method based on presence of level
    String method = 'level-up';
    if (level == null) {
      // Si no tiene nivel, asumimos que es TM/máquina (el método más común sin nivel)
      method = 'machine';
    }

    final versionGroupData = json['pokemon_v2_versiongroup'] as Map<String, dynamic>?;
    String versionGroup = 'latest';
    if (versionGroupData != null) {
      versionGroup = versionGroupData['name'] as String? ?? 'latest';
    }

    return PokemonMove(
      name: name,
      method: method,
      level: level,
      versionGroup: versionGroup,
    );
  }

  static String getMethodDisplay(String method) {
    switch (method.toLowerCase()) {
      case 'level-up':
        return 'Nivel';
      case 'machine':
        return 'TM/HM';
      case 'tutor':
        return 'Tutor';
      case 'egg':
        return 'Huevo';
      default:
        return method;
    }
  }
}
