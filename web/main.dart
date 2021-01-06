import 'dart:html';

import 'dart/actions.dart' as actions;
import 'dart/communication.dart';
import 'dart/game.dart';
import 'dart/locals.dart';
import 'dart/player.dart';

TextAreaElement answerField;

void main() async {
  querySelector('#output').text = 'Your Dart app is running.';

  await wsConnect(handleEvent);
  print('WebSocket connected!');

  Game.createGame();

  answerField = querySelector('#answerField')
    ..onKeyDown.listen((e) {
      // [Enter] key
      if (e.keyCode == 13) {
        e.preventDefault();
        submitAnswer();
      }
    });

  querySelector('#joinCode').onKeyDown.listen((e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      sendAction(actions.GAME_JOIN, {
        'code': (e.target as InputElement).value,
        'name': player.name,
      });
    }
  });
}

void submitAnswer() {
  var answer = answerField.value;
  game.submitAnswer(answer);
}

Null handleEvent(dynamic action, [Map<String, dynamic> json]) {
  switch (action) {
    case actions.EVENT_PLAYER_JOIN:
      return game.onPlayerJoin(Player(json));
    case actions.EVENT_GAME_JOIN:
      game = Game(json);
      return print('Joined Game ${game.code}!');
    case actions.EVENT_PLAYER_LEAVE:
      return game.onPlayerLeave(json['id']);
  }
  throw UnsupportedError('Event $action not implemented');
}
