import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:factum/models/match_all_mode_model.dart';

import 'input_player_data.dart';

class InputPlayersFacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var matchAllFriendsNotifier = context.watch<MatchAllFriendsNotifier>();
    var currentPlayer = matchAllFriendsNotifier.currentPlayerData;
    print(
        'InputPlayersFactsRebuild:${matchAllFriendsNotifier.model.currentPlayer}');
    if (matchAllFriendsNotifier.model.currentState ==
        GameState.answeringState) {
      Future.microtask(
        () => Navigator.of(context).pushReplacementNamed('/match_all_game'),
      );
      return Container();
    }
    return WaitNextPlayer(
      key: ValueKey(matchAllFriendsNotifier.model.currentPlayer),
      player: currentPlayer,
      child: InputPlayerDataScreen(
        image: currentPlayer.image,
        inputTitle: 'Введи факт о себе',
      ),
    );
  }
}

typedef BuilderFunction(BuildContext context);

class WaitNextPlayer extends StatefulWidget {
  final PlayerData player;
  final Widget child;
  WaitNextPlayer(
      {@required this.player, @required this.child, @required Key key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _WaitNextPlayerState();
}

class _WaitNextPlayerState extends State<WaitNextPlayer>
    with TickerProviderStateMixin {
  AnimationController _countDownController;
  final int _timerSeconds = 3;

  @override
  void initState() {
    super.initState();
    _countDownController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timerSeconds),
    );
    _countDownController.forward().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _countDownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_countDownController.isCompleted) {
      return widget.child;
    }
    return SafeArea(
      child: Scaffold(
        appBar: null,
        body: AnimatedBuilder(
          animation: _countDownController,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context).textTheme.headline4,
                      children: <TextSpan>[
                        TextSpan(text: 'Передай телефон игроку '),
                        TextSpan(
                          text: '${widget.player.name}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              .copyWith(color: Theme.of(context).accentColor),
                        ),
                      ]),
                ),
                SizedBox(height: 20.0),
                Text(
                  '${_timerSeconds - (_countDownController.duration * _countDownController.value).inSeconds}',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
