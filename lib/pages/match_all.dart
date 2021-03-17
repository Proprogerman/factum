import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:factum/models/match_all_mode_model.dart';
import 'package:factum/pages/input_players_facts.dart';
import 'package:factum/widgets/matchable_lists.dart';
import 'package:factum/widgets/wait_next_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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

  LinkedScrollControllerGroup _controllers;
  ScrollController _pController, _fController;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _pController = _controllers.addAndGet();
    _fController = _controllers.addAndGet();
    var questions = Provider.of<MatchAllFriendsNotifier>(context, listen: false)
        .model
        .getQuestions();
    _players = questions.players;
    _facts = questions.facts;
  }

  @override
  void dispose() {
    _pController.dispose();
    _fController.dispose();
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
            Expanded(child: MatchableLists(players: _players, facts: _facts)),
            SizedBox(height: 16.0),
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
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

enum ItemType { playerItem, factItem }

class MatchItemData {
  int index;
  ItemType type;
  MatchItemData(this.index, this.type);
  @override
  bool operator ==(other) =>
      other is MatchItemData && index == other.index && type == other.type;
  @override
  int get hashCode => index.hashCode ^ type.hashCode;
}

class MatchableLists extends StatefulWidget {
  final List<MapEntry<int, PlayerData>> players;
  final List<MapEntry<int, String>> facts;
  MatchableLists({@required this.players, @required this.facts});
  @override
  _MatchableListsState createState() => _MatchableListsState();
}

typedef ListItemTappedCallback = void Function(MatchItemData itemData);

class _MatchableListsState extends State<MatchableLists>
    with SingleTickerProviderStateMixin {
  List<MapEntry<int, PlayerData>> _players;
  List<MapEntry<int, String>> _facts;
  List<MatchableItem> playerItems, factItems;

  MatchItemData lastTappedItemData;

  AnimationController _controller;
  List<Animation<Offset>> animations;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addStatusListener((status) {
            print('animation status changed:::${status.toString()}');
            if (status == AnimationStatus.completed) {
              setState(() => generateItems());
              initializeAnimations();
              _controller.reset();
            }
          });

    _players = widget.players;
    _facts = widget.facts;
    initializeAnimations();
    generateItems();
  }

  void initializeAnimations() {
    animations = List<Animation<Offset>>.generate(
        _players.length,
        (_) => Tween<Offset>(begin: Offset.zero, end: Offset.zero)
            .animate(_controller));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              children: List<Widget>.generate(
                  playerItems.length,
                  (index) =>
                      Flexible(child: playerItems[index] as PlayerListItem)),
            ),
          ),
          Expanded(
            child: Column(
              children: List<Widget>.generate(
                factItems.length,
                (index) => Flexible(
                    child: SlideTransition(
                  position: animations[index],
                  child: factItems[index] as FactListItem,
                )),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _tapItemCallback(MatchItemData itemData) {
    print('tapItemCallback (${itemData.index}, ${itemData.type.toString()})');
    var currentList =
        (itemData.type == ItemType.playerItem ? playerItems : factItems);
    if (lastTappedItemData?.type == itemData.type) {
      if (lastTappedItemData.index != itemData.index)
        currentList[lastTappedItemData.index].setActive(false);
    } else if (lastTappedItemData != null) {
      swapItems(lastTappedItemData, itemData);
      return;
    }
    if (lastTappedItemData != itemData) {
      currentList[itemData.index].setActive(true);
      lastTappedItemData = itemData;
    } else {
      currentList[itemData.index].setActive(false);
      lastTappedItemData = null;
    }
  }

  void swapItems(
      MatchItemData targetItemData, MatchItemData subTargetItemData) {
    final playerIndex = targetItemData.type == ItemType.playerItem
        ? targetItemData.index
        : subTargetItemData.index;
    final factIndex = targetItemData.type == ItemType.factItem
        ? targetItemData.index
        : subTargetItemData.index;
    if (playerIndex == factIndex) return;
    playerItems[playerIndex].setActive(false);
    factItems[factIndex].setActive(false);
    print('swap items: $playerIndex <-> $factIndex');
    var fact = _facts[factIndex];
    _facts[factIndex] = _facts[playerIndex];
    _facts[playerIndex] = fact;
    lastTappedItemData = null;
    setState(() {
      animations[factIndex] = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0.0, (playerIndex - factIndex).toDouble()))
          .animate(
        CurvedAnimation(curve: Curves.easeInOut, parent: _controller),
      );
      animations[playerIndex] = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0.0, (factIndex - playerIndex).toDouble()))
          .animate(
        CurvedAnimation(curve: Curves.easeInOut, parent: _controller),
      );
      _controller.forward();
      // generateItems();
    });
  }

  void generateItems() {
    print('generateItems!!!!');
    playerItems = List<PlayerListItem>.generate(
      _players.length,
      (int index) => PlayerListItem(
          key: UniqueKey(),
          player: _players[index].value,
          index: index,
          tappedCallback: _tapItemCallback),
    );
    factItems = List<FactListItem>.generate(
      _facts.length,
      (int index) => FactListItem(
        key: UniqueKey(),
        fact: _facts[index].value,
        index: index,
        tappedCallback: _tapItemCallback,
        isFirst: index == 0,
        isLast: index == _facts.length - 1,
      ),
    );
  }
}

class SetActiveController {
  void Function(bool active) setActiveCallback;
}

abstract class MatchableItem {
  void setActive(bool active);
}

class PlayerListItem extends StatefulWidget implements MatchableItem {
  final PlayerData player;
  final SetActiveController setActiveController = SetActiveController();

  final int index;
  final ListItemTappedCallback tappedCallback;

  PlayerListItem({
    @required this.player,
    @required this.index,
    @required this.tappedCallback,
    @required Key key,
  }) : super(key: key);

  void setActive(bool active) => setActiveController.setActiveCallback(active);

  @override
  _PlayerListItemState createState() => _PlayerListItemState(
      setActiveController: setActiveController, player: player);
}

class _PlayerListItemState extends State<PlayerListItem> {
  bool active = false;

  _PlayerListItemState(
      {SetActiveController setActiveController, PlayerData player}) {
    print('setActiveController_' + player.name);
    setActiveController.setActiveCallback = _setActive;
  }

  void _setActive(bool active) {
    setState(() {
      this.active = active;
    });
  }

  void _onTap() =>
      widget.tappedCallback(MatchItemData(widget.index, ItemType.playerItem));

  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.5,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: widget.player.image),
          ),
          Container(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(.0, 0.8),
                  end: Alignment(.0, 0.3),
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: Text(
                  widget.player.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: active ? 0.3 : 0.0,
            duration: Duration(milliseconds: 250),
            child: Container(color: Colors.purple[200]),
          ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent, child: InkWell(onTap: _onTap)),
          )
        ],
      ),
    );
  }
}

class FactListItem extends StatefulWidget implements MatchableItem {
  final String fact;
  final SetActiveController setActiveController = SetActiveController();

  final int index;
  final ListItemTappedCallback tappedCallback;
  final bool isFirst;
  final bool isLast;

  FactListItem(
      {@required Key key,
      @required this.fact,
      @required this.index,
      @required this.tappedCallback,
      @required this.isFirst,
      @required this.isLast})
      : super(key: key);

  void setActive(bool active) => setActiveController.setActiveCallback(active);

  @override
  _FactListItemState createState() =>
      _FactListItemState(setActiveController: setActiveController);
}

class _FactListItemState extends State<FactListItem> {
  bool active = false;
  _FactListItemState({SetActiveController setActiveController}) {
    setActiveController.setActiveCallback = _setActive;
  }

  void _setActive(bool active) {
    setState(() {
      this.active = active;
    });
  }

  void _onTap() =>
      widget.tappedCallback(MatchItemData(widget.index, ItemType.factItem));

  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.5,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                  top: !widget.isFirst
                      ? BorderSide(color: Colors.grey)
                      : BorderSide.none,
                  bottom: !widget.isLast
                      ? BorderSide(color: Colors.grey)
                      : BorderSide.none),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  widget.fact,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: active ? 0.3 : 0.0,
            duration: Duration(milliseconds: 250),
            child: Container(color: Colors.purple[200]),
          ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent, child: InkWell(onTap: _onTap)),
          )
        ],
      ),
    );
  }
}
