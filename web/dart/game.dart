import 'dart:html';

import 'actions.dart';
import 'communication.dart';
import 'locals.dart';
import 'player.dart';

class Game {
  final String code;
  List<String> _questions;
  final _players = <Player>[];

  Game(Map<String, dynamic> json) : code = json['code'] {
    _questions = List<String>.from(json['questions']);
    for (var pJson in json['players']) {
      onPlayerJoin(Player(pJson));
    }
    onPlayerJoin(player);
    print(_questions);
    querySelector('h1').text = 'Game code: $code';
  }

  static void createGame() => sendAction(GAME_CREATE, {'name': player.name});

  void onPlayerJoin(Player player) {
    _players.add(player);
    print('$player joined the game');
  }

  void onPlayerLeave(String playerName) {
    _players.removeWhere((p) => p.name == playerName);
    print('$playerName left the game');
  }

  Future<void> submitAnswer(String answer) =>
      sendJobAction(GAME_SUBMIT_ANSWER, {'answer': answer});
}
