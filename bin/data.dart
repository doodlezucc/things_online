import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../web/dart/actions.dart' as actions;
import 'random_string.dart';

final allGames = <Game>[];
final allPlayers = <Player>[];
List<String> allQuestions;

void readQuestions() async {
  var file = File('data/questions');
  allQuestions = await file.readAsLines();
  print('Read all questions!');
}

class Game {
  final String code;
  final _questions = <String>[];
  final _players = <Player>[];
  Player get host => _players.isEmpty ? null : _players.first;

  Game({@required this.code, @required Player host}) {
    _questions.addAll(allQuestions);
    addPlayer(host);
  }

  static String _generateCode() => getRandomString(4);

  static Game create(Player host) {
    var code = _generateCode();
    while (allGames.any((game) => game.code == code)) {
      code = _generateCode();
    }
    return Game(code: code, host: host);
  }

  void addPlayer(Player p) {
    _players.add(p);
    for (var all in _players) {
      all.send(actions.EVENT_PLAYER_JOIN);
    }
  }

  void removePlayer(Player p) {
    _players.remove(p);
  }

  void log(Object msg) => print('Game $code: $msg');
}

class Player {
  final WebSocketChannel webSocket;

  void send(String action, [Map<String, dynamic> json]) {
    webSocket.sink.add(jsonEncode({
      'action': action,
    }));
  }

  Player(this.webSocket) {
    webSocket.stream.listen((data) async {
      print(data);
      if (data is String && data[0] == '{') {
        var json = jsonDecode(data);

        var result = await handleAction(json['action'], json['params']);

        var id = json['id'];
        if (id != null) {
          webSocket.sink.add(jsonEncode({'id': id, 'result': result}));
        }
      }
    });
  }

  Future<dynamic> handleAction(
      String action, Map<String, dynamic> params) async {
    switch (action) {
      case actions.GAME_CREATE:
        return createGame();
    }
    stderr.addError(UnsupportedError('Action $action is not implemented.'));
    return null;
  }

  dynamic createGame() {
    var game = Game.create(this);
    allGames.add(game);
    game.log('Created!');
    return {'code': game.code, 'questions': game._questions};
  }
}
