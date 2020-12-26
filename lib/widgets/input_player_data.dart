import 'dart:math';

import 'package:factum/models/match_all_mode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum InputPlayerDataScreenMode { nameInput, factInput }

class InputPlayerDataScreen extends StatefulWidget {
  final Image image;
  final InputPlayerDataScreenMode inputMode;

  InputPlayerDataScreen(
      {Key key, @required this.image, @required this.inputMode})
      : super(key: key);

  @override
  _InputPlayerDataScreenState createState() => _InputPlayerDataScreenState();
}

class _InputPlayerDataScreenState extends State<InputPlayerDataScreen> {
  TextEditingController textController = TextEditingController();

  bool isValidText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getInputTitle())),
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
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: FittedBox(fit: BoxFit.cover, child: widget.image),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: textController,
                      maxLength: _getMaxInputLength(),
                      keyboardType: TextInputType.text,
                      //TODO: запрещать вводить лишние пробелы
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.deny(RegExp(r""))
                      // ],
                      onChanged: (value) {
                        setState(() {
                          isValidText = !value.isEmpty &&
                              value.length <= _getMaxInputLength();
                        });
                      },
                      autofocus: true,
                      textAlign: TextAlign.center,
                      maxLines: null,
                      style: TextStyle(
                        fontSize:
                            (MediaQuery.of(context).size.height * 0.25) / 5,
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
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          backgroundColor: !isValidText ? null : Theme.of(context).primaryColor,
          child: Icon(Icons.done),
          onPressed: !isValidText ? null : () => _doneButtonAction(context),
        ),
      ),
    );
  }

  String _getInputTitle() {
    switch (widget.inputMode) {
      case InputPlayerDataScreenMode.nameInput:
        return 'Введи своё имя';
      case InputPlayerDataScreenMode.factInput:
        return 'Введи факт о себе';
      default:
        return '';
    }
  }

  int _getMaxInputLength() {
    switch (widget.inputMode) {
      case InputPlayerDataScreenMode.nameInput:
        return 26;
      case InputPlayerDataScreenMode.factInput:
        return 52;
      default:
        return null;
    }
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
