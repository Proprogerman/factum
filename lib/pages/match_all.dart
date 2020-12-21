import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:factum/models/match_all_mode_model.dart';
import 'package:factum/pages/input_players_facts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:provider/provider.dart';

class MatchAllGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var matchAllFriendsNotifier = context.watch<MatchAllFriendsNotifier>();
    var currentPlayer = matchAllFriendsNotifier.currentPlayerData;
    if (matchAllFriendsNotifier.model.currentState == GameState.finalState) {
      Future.microtask(
        () => Navigator.of(context).pushReplacementNamed('/results'),
      );
      return Container();
    }
    return WaitNextPlayer(
      key: ValueKey(matchAllFriendsNotifier.model.currentPlayer),
      player: currentPlayer,
      child: MatchAll(),
    );
  }
}

class MatchAll extends StatefulWidget {
  @override
  _MatchAllState createState() => _MatchAllState();
}

class _MatchAllState extends State<MatchAll> {
  bool accepted = false;
  List<MapEntry<int, PlayerData>> _players;
  List<MapEntry<int, String>> _facts;

  final playersScrollController = ScrollController();
  final factsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var questions = Provider.of<MatchAllFriendsNotifier>(context, listen: false)
        .model
        .getQuestions();
    _players = questions.players;
    _facts = questions.facts;
  }

  @override
  void dispose() {
    playersScrollController.dispose();
    factsScrollController.dispose();
    super.dispose();
  }

  bool _reorderPlayerCallback(Key item, Key newItem) {
    int draggingIndex =
        _players.indexOf((item as ValueKey<MapEntry<int, PlayerData>>).value);
    int newPositionIndex = _players
        .indexOf((newItem as ValueKey<MapEntry<int, PlayerData>>).value);

    final draggedItem = _players[draggingIndex];
    setState(() {
      _players.removeAt(draggingIndex);
      _players.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  bool _reorderFactCallback(Key item, Key newItem) {
    int draggingIndex =
        _facts.indexOf((item as ValueKey<MapEntry<int, String>>).value);
    int newPositionIndex =
        _facts.indexOf((newItem as ValueKey<MapEntry<int, String>>).value);

    final draggedItem = _facts[draggingIndex];
    setState(() {
      _facts.removeAt(draggingIndex);
      _facts.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _doneCallback(BuildContext context) {
    assert(_players.length == _facts.length, 'неверное состояние ответов');
    var answers = List<Answer>();
    for (int i = 0; i < _players.length; i++) {
      answers.add(Answer(_players[i].key, _facts[i].key));
    }
    Provider.of<MatchAllFriendsNotifier>(context, listen: false)
        .giveAnswers(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Угадай друзей по фактам'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverFillRemaining(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: ReorderableList(
                            onReorder: this._reorderPlayerCallback,
                            child: CustomScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return ReorderableItem(
                                        key: ValueKey(_players[index]),
                                        childBuilder: (context, state) {
                                          return PlayerListItem(
                                            player: _players[index].value,
                                            state: state,
                                          );
                                        },
                                      );
                                    },
                                    childCount: _players.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: ReorderableList(
                            onReorder: this._reorderFactCallback,
                            child: CustomScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return ReorderableItem(
                                        key: ValueKey(_facts[index]),
                                        childBuilder: (context, state) {
                                          return FactListItem(
                                            isFirst: index == 0,
                                            isLast: index == _facts.length - 1,
                                            fact: _facts[index].value,
                                            state: state,
                                          );
                                        },
                                      );
                                    },
                                    childCount: _facts.length,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ButtonTheme(
                  minWidth: 200,
                  height: 62,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Готово',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    onPressed: () => _doneCallback(context),
                  )),
            ),
            SizedBox(height: 33.0),
          ],
        ),
      ),
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final ReorderableItemState state;
  final PlayerData player;
  PlayerListItem({@required this.player, @required this.state});

  Widget build(BuildContext context) {
    return DelayedReorderableListener(
      delay: Duration(milliseconds: 250),
      child: Opacity(
        opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
        child: SizedBox(
          height: 125,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: player.image),
              ),
              Container(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      end: FractionalOffset.bottomCenter,
                      begin: FractionalOffset.center,
                      colors: [
                        Colors.grey.withOpacity(0.0),
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: [0.0, 0.65],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    child: Text(player.name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FactListItem extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final ReorderableItemState state;
  final String fact;
  FactListItem(
      {@required this.fact,
      @required this.state,
      @required this.isFirst,
      @required this.isLast});

  Widget build(BuildContext context) {
    final bool isPlaceholder = state == ReorderableItemState.placeholder;
    return DelayedReorderableListener(
      delay: Duration(milliseconds: 250),
      child: Opacity(
        opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
        child: SizedBox(
          height: 125,
          width: double.infinity,
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: !isFirst && !isPlaceholder
                      ? Divider.createBorderSide(context, width: 1.0)
                      : BorderSide.none,
                  bottom: !isLast && !isPlaceholder
                      ? Divider.createBorderSide(context, width: 1.0)
                      : BorderSide.none,
                ),
              ),
              child: Center(
                child: Text(fact,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center),
              )),
        ),
      ),
    );
  }
}
