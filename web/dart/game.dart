import 'actions.dart';
import 'communication.dart';

class Game {
  final String code;
  List<String> _questions;

  Game(Map<String, dynamic> json) : code = json['code'] {
    _questions = List<String>.from(json['questions']);
    print(_questions);
  }

  static Future<Game> createGame() async {
    var response = await request(GAME_CREATE);
    return Game(response);
  }

  Future<void> submitAnswer(String answer) =>
      request(GAME_SUBMIT_ANSWER, {'answer': answer});
}
