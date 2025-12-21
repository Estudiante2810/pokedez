// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_ability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonAbilityAdapter extends TypeAdapter<PokemonAbility> {
  @override
  final int typeId = 2;

  @override
  PokemonAbility read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonAbility(
      name: fields[0] as String,
      isHidden: fields[1] as bool,
      effect: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonAbility obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.isHidden)
      ..writeByte(2)
      ..write(obj.effect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonAbilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
