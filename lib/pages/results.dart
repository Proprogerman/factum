import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:factum/models/match_all_mode_model.dart';
import 'package:factum/widgets/input_player_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  var results = List<ResultPlayerData>();
  var currentPlayer = 0;

  ResultPlayerData get currentResult => results[currentPlayer];
  bool get isFirstResult => currentPlayer == 0;
  bool get isLastResult => currentPlayer == results.length - 1;

  @override
  void initState() {
    super.initState();
    results = Provider.of<MatchAllFriendsNotifier>(context, listen: false)
        .model
        .getPlayersResults();
    _controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    _animation = _controller.drive(Tween<double>(begin: 1.0, end: 2.0));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextResult() {
    print('$currentPlayer');
    if (isLastResult) return;
    setState(() {
      currentPlayer++;
      _controller.reset();
      _controller.forward();
    });
  }

  void prevResult() {
    if (isFirstResult) return;
    setState(() {
      currentPlayer--;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ScaleTransition(
              alignment: Alignment.center,
              scale: _animation,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      child: currentResult.player.image),
                ), //currentResult.player.image,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 124.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius:
                                BorderRadius.all(Radius.circular(17.0)),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(13.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AutoSizeText.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: Colors.white),
                                    children: <TextSpan>[
                                      TextSpan(text: 'Игрок '),
                                      TextSpan(
                                        text: '${currentResult.player.name}\n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .accentColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Colors.white),
                                AutoSizeText.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: Colors.white),
                                    children: <TextSpan>[
                                      TextSpan(text: '\u00AB'),
                                      TextSpan(
                                        text: '${currentResult.fact}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .accentColor),
                                      ),
                                      TextSpan(text: '\u00BB'),
                                    ],
                                  ),
                                ),
                                AutoSizeText.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(color: Colors.white),
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        text: '${currentResult.achievement}',
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                //TODO:решить проблему с вёрсткой
                                SizedBox(
                                  height: 100,
                                  child: PlayersKnowYouList(
                                      currentResult.playersKnowYou),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(13.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor:
                          isFirstResult ? null : Theme.of(context).primaryColor,
                      child: Transform(
                        transform: Matrix4.rotationY(pi),
                        alignment: Alignment.center,
                        child: Icon(Icons.forward),
                      ),
                      onPressed: isFirstResult ? null : () => this.prevResult(),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor:
                          isLastResult ? null : Theme.of(context).primaryColor,
                      child: Icon(Icons.forward),
                      onPressed: isLastResult ? null : () => this.nextResult(),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlayersKnowYouList extends StatelessWidget {
  final List<PlayerData> players;
  PlayersKnowYouList(this.players);
  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return Container();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Угадали:',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 4.0),
          Expanded(
            child: ListView.separated(
              itemCount: players.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => SizedBox(width: 8.0),
              itemBuilder: (_, index) {
                return SizedBox(
                  width: 54,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        clipper: CameraCircleClipper(),
                        child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi),
                            child: SizedBox(
                              height: 54,
                              width: 54,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: players[index].image,
                              ),
                            )),
                      ),
                      Expanded(
                        child: Text(
                          players[index].name,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
