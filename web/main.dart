import 'dart:html';

import 'dart/communication.dart';
import 'dart/game.dart';
import 'dart/locals.dart';

TextAreaElement answerField;

void main() async {
  querySelector('#output').text = 'Your Dart app is running.';

  await wsConnect();
  print('Connected!');

  game = await Game.createGame();
  print('Game ${game.code} created!');

  answerField = querySelector('#answerField')
    ..onKeyDown.listen((e) {
      if (e.keyCode == 13) {
        // [Enter] key
        e.preventDefault();
        submitAnswer();
      }
    });
}

void submitAnswer() {
  var answer = answerField.value;
  game.submitAnswer(answer);
}
