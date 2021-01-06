import 'dart:async';
import 'dart:convert';
import 'dart:html';

WebSocket _webSocket;

Future<void> wsConnect(
    void Function(dynamic action, Map<String, dynamic> params) eventHandler) {
  var completer = Completer();
  var secure = window.location.href.startsWith('https') ? 's' : '';

  _webSocket = WebSocket('ws$secure://localhost:7070/ws')
    ..onOpen.listen((e) => completer.complete())
    ..onClose.listen((e) => print('CLOSE'))
    ..onError.listen((e) => print(e))
    ..onMessage.listen((e) {
      var data = e.data;
      print(data);
      if (data is String && data.startsWith('{')) {
        var json = jsonDecode(data);
        var action = json['action'];
        if (action != null) {
          eventHandler(action, json['params']);
        }
      }
    });

  return completer.future;
}

void performAction(dynamic action, [Map<String, String> params]) {
  _webSocket.send(jsonEncode({
    'action': action,
    if (params != null) 'params': params,
  }));
}

int _jobId = 0;

Future<dynamic> request(dynamic action, [Map<String, String> params]) async {
  var myId = _jobId++;
  var json = jsonEncode({
    'id': myId,
    'action': action,
    if (params != null) 'params': params,
  });
  _webSocket.send(json);

  var msg = await _webSocket.onMessage.firstWhere(
      (msg) => msg.data is String && msg.data.startsWith('{"id":$myId,'));

  _jobId--;
  return jsonDecode(msg.data)['result'];
}
