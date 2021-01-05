import 'dart:math';

final _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//final _lowercase = _uppercase.toLowerCase();
//final _chars = '1234567890$_uppercase$_lowercase';
final _chars = _uppercase;
final _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
