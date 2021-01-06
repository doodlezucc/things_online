import 'actions.dart';
import 'communication.dart';
import 'locals.dart';
import 'player.dart';

class Game {
  final String code;
  List<String> _questions;
  List<Player> _players;

  Game(Map<String, dynamic> json) : code = json['code'] {
    _questions = List<String>.from(json['questions']);
    _players = [player, ...json['players'].map((j) => Player(j))];
    print(_questions);
    print(_players);
  }

  static void createGame() => performAction(GAME_CREATE);

  void onPlayerJoin(Player player) {
    _players.add(player);
    print('Player $player joined the game');
  }

  void onPlayerLeave(Player player) {
    _players.remove(player);
    print('Player $player left the game');
  }

  Future<void> submitAnswer(String answer) =>
      request(GAME_SUBMIT_ANSWER, {'answer': answer});
}
