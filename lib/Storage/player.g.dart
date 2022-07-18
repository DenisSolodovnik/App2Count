// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      identifier: json['identifier'] as String? ?? "",
      points: json['points'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      colorValue: json['colorValue'] as int? ?? -1,
      pointsDelta: json['pointsDelta'] as int? ?? 0,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'identifier': instance.identifier,
      'points': instance.points,
      'name': instance.name,
      'colorValue': instance.colorValue,
      'pointsDelta': instance.pointsDelta,
    };
