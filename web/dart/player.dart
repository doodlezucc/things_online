class Player {
  String _name;
  String get name => _name;

  Player(Map<String, dynamic> json) {
    onNameChange(json['name']);
  }

  void onNameChange(String name) {
    print("$_name's name is now $name");
    _name = name;
  }

  @override
  String toString() => name;
}

class LocalPlayer extends Player {
  LocalPlayer()
      : super({
          'name': 'Player One',
        });
}
