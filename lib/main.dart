import 'package:factum/pages/add_player.dart';
import 'package:factum/pages/input_players_facts.dart';
import 'package:factum/pages/match_all.dart';
import 'package:factum/pages/players.dart';
import 'package:factum/pages/results.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'common/theme.dart';

import 'package:provider/provider.dart';

import 'models/match_all_mode_model.dart';

var routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale locale;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MatchAllFriendsNotifier.loadTestData(),
      child: MaterialApp(
        title: 'Factum',
        theme: appTheme,
        initialRoute: '/players',
        routes: {
          '/players': (_) => PlayersScreen(),
          '/add_player': (_) => AddPlayerScreen(),
          '/match_all_game': (_) => MatchAllGame(),
          '/input_players_facts': (_) => InputPlayersFacts(),
          '/results': (_) => ResultScreen(),
        },
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
