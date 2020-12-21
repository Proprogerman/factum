import 'dart:math';

import 'package:factum/models/match_all_mode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class InputPlayerDataScreen extends StatefulWidget {
  final String inputTitle;
  final Image image;

  InputPlayerDataScreen(
      {Key key, @required this.inputTitle, @required this.image})
      : super(key: key);

  @override
  _InputPlayerDataScreenState createState() => _InputPlayerDataScreenState();
}

class _InputPlayerDataScreenState extends State<InputPlayerDataScreen> {
  TextEditingController textController = TextEditingController();

  bool isDataEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.inputTitle)),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Builder(
                builder: (context) => SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      Scaffold.of(context).appBarMaxHeight,
                  child: ClipOval(
                    clipper: CameraCircleClipper(),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child:
                          FittedBox(fit: BoxFit.contain, child: widget.image),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: IntrinsicHeight(
                  child: TextField(
                    controller: textController,
                    onChanged: (value) {
                      setState(() {
                        isDataEmpty = value.isEmpty;
                      });
                    },
                    autofocus: true,
                    textAlign: TextAlign.center,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.height * 0.25) / 5,
                      color: Colors.black,
                      background: Paint()
                        ..color = Colors.grey[300]
                        ..style = PaintingStyle.stroke
                        ..strokeJoin = StrokeJoin.round
                        ..strokeWidth = 56.0,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: isDataEmpty ? null : () => _doneButtonAction(context),
        ),
      ),
    );
  }

  void _doneButtonAction(BuildContext context) {
    var matchAllFriendsNotifier =
        Provider.of<MatchAllFriendsNotifier>(context, listen: false);
    print(
        '_doneButtonAction:currentState - ${matchAllFriendsNotifier.model.currentState.toString()}');
    switch (matchAllFriendsNotifier.model.currentState) {
      case GameState.noGameState:
        matchAllFriendsNotifier.addPlayer(
          PlayerData(
            name: textController.text,
            image: widget.image,
          ),
        );
        Navigator.of(context).popUntil(ModalRoute.withName('/players'));
        break;
      case GameState.preparingState:
        matchAllFriendsNotifier.inputFact(textController.text);
        break;
      default:
        return;
    }
  }
}

class CameraCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.width);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
