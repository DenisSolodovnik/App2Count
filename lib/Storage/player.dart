import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player extends Equatable {
  final String identifier;
  final int points;
  final String name;
  final int colorValue;
  final int pointsDelta;

  // constructor

  const Player({this.identifier = "", this.points = 0, this.name = "", this.colorValue = -1, this.pointsDelta = 0});

  factory Player.from(Player player,
      {String? identifier, int? points, String? name, int? colorValue, int? pointsDelta}) {
    return Player(
        identifier: identifier ?? player.identifier,
        points: points ?? player.points,
        name: name ?? player.name,
        colorValue: colorValue ?? player.colorValue,
        pointsDelta: pointsDelta ?? player.pointsDelta);
  }

  // getters

  int totalScore() {
    return points + pointsDelta;
  }

  Color get color {
    return Color(colorValue);
  }

  String scoreString() {
    return totalScore().toString();
  }

  String scoreDeltaString() {
    String delta = '';
    if (pointsDelta > 0) {
      delta = '+';
    }
    delta += pointsDelta.toString();
    return delta;
  }

  String scoreCalculationString() {
    return points.toString() +
        (pointsDelta < 0 ? " - " : " + ") +
        pointsDelta.abs().toString() +
        " = " +
        totalScore().toString();
  }

  // json

  @override
  List<Object> get props => [identifier, points, name, colorValue, pointsDelta];

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
