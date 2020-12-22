import 'dart:io';
import 'dart:math';

import 'package:factum/models/match_all_mode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class PlayersScreen extends StatefulWidget {
  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPopNext() {
    Provider.of<MatchAllFriendsNotifier>(context, listen: false).cancelGame();
  }

  @override
  Widget build(BuildContext context) {
    var matchAllFriendsNotifier = context.watch<MatchAllFriendsNotifier>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Игроки',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    RawMaterialButton(
                      constraints: BoxConstraints(minWidth: 40.0),
                      fillColor: Theme.of(context).buttonColor,
                      elevation: 2.0,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8.0),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/add_player');
                      },
                      child: Icon(
                        Icons.add,
                        size: 36.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: matchAllFriendsNotifier.model.players.entries
                      .map((player) => _PlayerChip(player))
                      .toList(),
                ),
              ),
            ),
            Spacer(),
            Center(
              child: ButtonTheme(
                minWidth: 200,
                height: 62,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: RaisedButton(
                  child: Text(
                    'Играть',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  onPressed: !matchAllFriendsNotifier.isReadyToPlay
                      ? null
                      : () {
                          matchAllFriendsNotifier.initGame();
                          Navigator.of(context)
                              .pushNamed('/input_players_facts');
                        },
                ),
              ),
            ),
            SizedBox(height: 33.0),
          ],
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final MapEntry<int, PlayerData> player;
  _PlayerChip(this.player);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Chip(
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13.0),
          child: Text(player.value.name),
        ),
        avatar: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: CircleAvatar(
            child: Container(),
            backgroundImage: player.value.image.image,
          ),
        ),
        onDeleted: () {
          Provider.of<MatchAllFriendsNotifier>(context, listen: false)
              .removePlayer(player.key);
        },
      ),
    );
  }
}
