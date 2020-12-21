import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PlayerData {
  int id;
  String info;
  String image;
  PlayerData({@required this.id, @required this.info, @required this.image});
}

class GameData {
  int numberOfPlayers;
  List<PlayerData> players = List<PlayerData>();

  var playersAnsers = Map<int, Map<int, String>>();

  GameData({@required this.numberOfPlayers});

  void addPlayer(PlayerData player) => players.add(player);

  bool needToAddNewPlayer() => numberOfPlayers > players.length;

  // void registerPlayerAnswer(int player, String )
}
