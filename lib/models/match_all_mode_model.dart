import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'dart:core';

import 'package:flutter/services.dart' show rootBundle;

class Answer {
  final int target; //id цели
  final int match; //предполагаемый id
  const Answer(this.target, this.match);

  bool get isCorrect => target == match;
}

class PlayerData {
  final String name;
  final Image image;
  const PlayerData({@required this.name, @required this.image});

  PlayerData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        image = Image.network(json['image']);
}

class PreparedQuestions {
  final List<MapEntry<int, PlayerData>> players;
  final List<MapEntry<int, String>> facts;
  const PreparedQuestions({this.players, this.facts});
}

class ResultPlayerData {
  final PlayerData player;
  final String fact;
  final List<PlayerData> playersKnowYou;
  final String achievement;
  ResultPlayerData(
      {this.player, this.fact, this.playersKnowYou, this.achievement});
}

enum GameState { noGameState, preparingState, answeringState, finalState }

abstract class MatchAllModeModel {
  // var _players = testPlayers;
  var _players = List<PlayerData>();

  //sessionData
  // мапа фактов
  var _facts = Map<int, String>();
  // мапа ответов: <проголосовавший игрок, лист ответов>
  var _answers = Map<int, List<Answer>>();
  // мапа правильных ответов для финальной страницы <цель, правильно угадавшие игроки>
  var _correctAnswers = Map<int, List<int>>();
  //

  Map<int, PlayerData> get players => _players.asMap();
  Map<int, String> get facts => _facts;
  int get currentPlayer => _currentPlayer;
  bool get isLastPlayer => _currentPlayer == (players.length - 1);
  GameState get currentState => _currentState;

  int _currentPlayer = 0;
  GameState _currentState = GameState.noGameState;

  void initGame() {
    assert(_players.length != 0, 'нет игроков');
    _initGameState(GameState.preparingState);
  }

  void _initGameState([GameState state = GameState.noGameState]) {
    if (state == GameState.noGameState) {
      _facts.clear();
      _answers.clear();
      _correctAnswers.clear();
    }
    _currentPlayer = 0;
    _currentState = state;
  }

  void cancelGame() {
    _initGameState();
  }

  void inputFact(String fact) {
    assert(
        _currentState == GameState.preparingState, 'неверное состояние игры');
    _facts[_currentPlayer] = fact;
    if (isLastPlayer) {
      _initGameState(GameState.answeringState);
      return;
    }
    _currentPlayer++;
  }

  void giveAnswers(List<Answer> playerMatches) {
    assert(
        _currentPlayer != null &&
            _currentPlayer >= 0 &&
            _currentPlayer < _players.length,
        'некорректное состояние игры');
    _answers.update(_currentPlayer, (value) => value..addAll(playerMatches),
        ifAbsent: () => playerMatches);
    for (Answer answer in playerMatches)
      if (answer.isCorrect)
        _correctAnswers.update(
            answer.target, (value) => value..add(_currentPlayer),
            ifAbsent: () => <int>[_currentPlayer]);
    if (isLastPlayer) {
      _initGameState(GameState.finalState);
      return;
    }
    _currentPlayer++;
  }
}

class MatchAllFriendsModeModel extends MatchAllModeModel {
  MatchAllFriendsModeModel() : super();

  Future<void> _loadTestUsers() async {
    List testPlayersList = jsonDecode(
        await rootBundle.loadString('test_data/local_game_data/players.json'));
    _players =
        testPlayersList.map((data) => PlayerData.fromJson(data)).toList();
  }

  void addPlayer(PlayerData player) => _players.add(player);
  void removePlayer(int playerPosition) => _players.removeAt(playerPosition);

  PreparedQuestions getQuestions() {
    var playerMap = Map<int, PlayerData>.from(players);
    var factMap = Map<int, String>.from(facts);
    return PreparedQuestions(
      players: ((playerMap..remove(currentPlayer)).entries.toList())
        ..shuffle(Random()),
      facts: ((factMap..remove(currentPlayer)).entries.toList())
        ..shuffle(Random()),
    );
  }

  List<ResultPlayerData> getPlayersResults() {
    var results = List<ResultPlayerData>();
    for (int pid = 0; pid < _players.length; pid++) {
      var player = _players[pid];
      var fact = _facts[pid];
      var knowYou = List<PlayerData>();
      if (_correctAnswers.containsKey(pid))
        for (var vl in _correctAnswers[pid]) knowYou.add(_players[vl]);

      String achievement = '';
      if (knowYou.isEmpty)
        achievement = 'От тебя этого никто не ожидал!';
      else if (knowYou.length == _players.length - 1)
        achievement = 'Тебя знают как облупленного!';

      results.add(ResultPlayerData(
          player: player,
          fact: fact,
          playersKnowYou: knowYou,
          achievement: achievement));
    }
    return results;
  }
}

class MatchAllFriendsNotifier extends ChangeNotifier {
  var _model = MatchAllFriendsModeModel();

  MatchAllFriendsNotifier() : super();

  MatchAllFriendsNotifier.loadTestData() : super() {
    _model._loadTestUsers().then((_) => notifyListeners());
  }

  void addPlayer(PlayerData player) {
    _model.addPlayer(player);
    notifyListeners();
  }

  void removePlayer(int playerPosition) {
    _model.removePlayer(playerPosition);
    notifyListeners();
  }

  void inputFact(String fact) {
    _model.inputFact(fact);
    notifyListeners();
  }

  void initGame() {
    _model.initGame();
    notifyListeners();
  }

  void cancelGame() {
    _model.cancelGame();
    notifyListeners();
  }

  void giveAnswers(List<Answer> playerMatches) {
    _model.giveAnswers(playerMatches);
    notifyListeners();
  }

  MatchAllFriendsModeModel get model => _model;

  int get playersCount => _model.players.length;
  bool get isReadyToPlay => _model.players.length >= 3;
  PlayerData get currentPlayerData => _model.players[_model.currentPlayer];
}

class MatchAllCelebsModeModel extends MatchAllModeModel {}
