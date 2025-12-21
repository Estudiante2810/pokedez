// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_evolution.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonEvolutionAdapter extends TypeAdapter<PokemonEvolution> {
  @override
  final int typeId = 3;

  @override
  PokemonEvolution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonEvolution(
      id: fields[0] as int,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      triggerType: fields[3] as String,
      triggerDetails: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonEvolution obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.triggerType)
      ..writeByte(4)
      ..write(obj.triggerDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonEvolutionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
