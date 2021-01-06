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
    p.send(actions.EVENT_GAME_JOIN, {
      'code': code,
      'players': _players.map((all) => all.toJson()).toList(),
      'questions': _questions
    });
    _players.add(p);
    sendAll(actions.EVENT_PLAYER_JOIN, params: p.toJson(), initiator: p);
  }

  void sendAll(dynamic action,
      {Map<String, dynamic> params, Player initiator}) {
    for (var all in _players) {
      if (all != initiator) all.send(action, params);
    }
  }

  void removePlayer(Player p) {
    _players.remove(p);
  }

  void log(Object msg) => print('Game $code: $msg');
}

class Player {
  final WebSocketChannel webSocket;
  String name;

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

  void send(String action, [Map<String, dynamic> params]) {
    webSocket.sink.add(jsonEncode({
      'action': action,
      if (params != null) 'params': params,
    }));
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

  void createGame() {
    var game = Game.create(this);
    allGames.add(game);
    game.log('Created!');
  }

  Map<String, dynamic> toJson() => {'name': name};
}
