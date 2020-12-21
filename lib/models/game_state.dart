import 'package:flutter/widgets.dart';

abstract class GameState {}

class NewUserState extends GameState {
  final bool init;
  NewUserState({@required this.init});
}

class MatchAllState extends GameState {}
