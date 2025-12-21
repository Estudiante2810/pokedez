// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_move.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonMoveAdapter extends TypeAdapter<PokemonMove> {
  @override
  final int typeId = 4;

  @override
  PokemonMove read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonMove(
      name: fields[0] as String,
      method: fields[1] as String,
      level: fields[2] as int?,
      versionGroup: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonMove obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.method)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.versionGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonMoveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
