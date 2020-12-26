import 'package:factum/models/match_all_mode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WaitNextPlayer extends StatefulWidget {
  final PlayerData player;
  final Widget child;
  WaitNextPlayer(
      {@required this.player, @required this.child, @required Key key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _WaitNextPlayerState();
}

class _WaitNextPlayerState extends State<WaitNextPlayer> {
  bool activated = false;
  @override
  Widget build(BuildContext context) {
    if (activated) {
      return widget.child;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          activated = true;
        });
      },
      child: SafeArea(
        child: Scaffold(
          appBar: null,
          body: GestureDetector(
            onTap: () {
              setState(() {
                activated = true;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 4,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: Theme.of(context).textTheme.headline3,
                          children: <TextSpan>[
                            TextSpan(text: 'Очередь игрока '),
                            TextSpan(
                              text: '${widget.player.name}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  .copyWith(
                                      color: Theme.of(context).accentColor),
                            ),
                          ]),
                    ),
                  ),
                  Spacer(flex: 1),
                  Flexible(
                    flex: 4,
                    child: Text(
                      'Нажмите, чтобы продолжить',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
