import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
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

List<String> questions;

void readQuestions() async {
  var file = File('data/questions');
  questions = await file.readAsLines();
  print('Read all questions!');
}

Response handleRequest(Request request) {
  var path = request.url.path;
  if (path == 'test') {
    return Response.ok(questions[Random().nextInt(questions.length)]);
  }
  return Response.ok('Request for "${request.url}"');
}
