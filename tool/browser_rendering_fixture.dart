import 'dart:io';

/// Local runtime rendering target, independent of any UI framework.
/// Exits after fifteen minutes; never substitutes for product acceptance.
Future<void> main(List<String> args) async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    args.isEmpty ? 51991 : int.parse(args.single),
  );
  stdout.writeln('Browser target: http://127.0.0.1:${server.port}');
  Future<void>.delayed(
    const Duration(minutes: 15),
    () => server.close(force: true),
  );
  await for (final request in server) {
    request.response.headers.contentType = ContentType.html;
    if (request.uri.path == '/second') {
      request.response.write(
        '<title>Second browser page</title>'
        '<h1>Navigation confirmed</h1><a href="/">Return to the canvas</a>',
      );
    } else {
      request.response.write(
        await File('test/browser/fixtures/rendering.html').readAsString(),
      );
    }
    await request.response.close();
  }
}
