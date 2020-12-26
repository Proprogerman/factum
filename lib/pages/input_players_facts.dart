import 'package:factum/widgets/wait_next_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:factum/models/match_all_mode_model.dart';

import '../widgets/input_player_data.dart';

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
        inputMode: InputPlayerDataScreenMode.factInput,
      ),
    );
  }
}
