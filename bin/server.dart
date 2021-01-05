import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart' as ws;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'data.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '7070';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(handleRequest);

  await readQuestions();

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

final FutureOr<Response> Function(Request) connectWebSocket =
    ws.webSocketHandler((WebSocketChannel webSocket) {
  print('New connection!');
  allPlayers.add(Player(webSocket));
});

Future<Response> handleRequest(Request request) async {
  var path = request.url.path;
  if (request.url.path.startsWith('ws')) {
    return connectWebSocket(request);
  } else if (path == 'test') {
    return Response.ok(allQuestions[Random().nextInt(allQuestions.length)]);
  }
  return Response.ok('Request for "${request.url}"');
}
