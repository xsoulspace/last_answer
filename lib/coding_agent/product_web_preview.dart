import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/product_candidate_verification.dart';

/// A local running product over compiled conventional Dart. The server exposes
/// only its compiled artifact and revision, never workspace files or tools.
/// Builds run in the existing contained compiler; a failed build keeps the
/// previous artifact. Source Undo therefore uses the ordinary native journal.
final class ProductWebPreview extends ChangeNotifier {
  ProductWebPreview(this.workspace, {ProductDartCandidateVerifier? compiler})
    : compiler = compiler ?? ProductDartCandidateVerifier(web: true);

  final Directory workspace;
  final ProductDartCandidateVerifier compiler;
  HttpServer? _server;
  StreamSubscription<FileSystemEvent>? _watch;
  Timer? _debounce;
  Future<void>? _building;
  bool _again = false;
  String? _javascript;
  String? _pendingJavascript;
  String? _pendingRevision;
  String? _failedRevision;
  String? revision;
  Map<String, Object?>? lastCheck;
  int activations = 0;
  final String _token = '${DateTime.now().microsecondsSinceEpoch}-$pid';
  Uri? get url => _server == null
      ? null
      : Uri.parse('http://127.0.0.1:${_server!.port}/$_token/');

  Map<String, Object?> toJson() => {
    'url': url?.toString(),
    'revision': revision,
    'pendingRevision': _pendingRevision,
    'activations': activations,
    'building': _building != null,
    'lastCheck': lastCheck,
    'workingVersionRetained': _javascript != null,
  };

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_serve);
    _watch = workspace.watch(recursive: true).listen((event) {
      if (!event.path.endsWith('.dart') ||
          event.path.contains('/.dart_tool/')) {
        return;
      }
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 250),
        () => unawaited(rebuild()),
      );
    });
    await rebuild();
  }

  Map<String, String> _sources() => {
    for (final file in workspace.listSync(recursive: true, followLinks: false))
      if (file is File &&
          file.path.endsWith('.dart') &&
          !file.path
              .substring(workspace.path.length + 1)
              .split('/')
              .any((p) => p.startsWith('.')))
        file.path.substring(workspace.path.length + 1): file.readAsStringSync(),
  };
  String _digest(Map<String, String> sources) => sha256
      .convert(
        utf8.encode(
          jsonEncode({
            for (final key in sources.keys.toList()..sort()) key: sources[key],
          }),
        ),
      )
      .toString();

  Future<void> rebuild() {
    if (_building != null) {
      _again = true;
      return _building!;
    }
    final done = Completer<void>();
    _building = done.future;
    unawaited(() async {
      try {
        do {
          _again = false;
          final source = _sources();
          final digest = _digest(source);
          if (digest == revision) {
            _pendingJavascript = null;
            _pendingRevision = null;
            continue;
          }
          if (digest == _pendingRevision || digest == _failedRevision) continue;
          final candidate = await Directory.systemTemp.createTemp(
            'product-web-',
          );
          try {
            for (final entry in source.entries) {
              final file = File('${candidate.path}/${entry.key}');
              file.parent.createSync(recursive: true);
              file.writeAsStringSync(entry.value);
            }
            final checked = await compiler.verifyCandidate(candidate);
            lastCheck = {'ok': checked.ok, ...checked.evidence};
            if (!checked.physicallySettled) {
              lastCheck = {...?lastCheck, 'retainedCandidate': candidate.path};
              break;
            }
            final output = File(
              '${candidate.path}/.dart_tool/coding_verification/main.js',
            );
            if (checked.ok &&
                output.existsSync() &&
                digest == _digest(_sources())) {
              _pendingJavascript = output.readAsStringSync();
              _pendingRevision = digest;
              lastCheck = {
                ...?lastCheck,
                'activation': 'awaiting_browser_smoke',
              };
            } else if (digest != _digest(_sources())) {
              _again = true;
            }
            await candidate.delete(recursive: true);
          } on Object catch (error) {
            lastCheck = {'ok': false, 'error': '$error'};
            if (candidate.existsSync()) await candidate.delete(recursive: true);
          }
          notifyListeners();
        } while (_again);
      } finally {
        _building = null;
        notifyListeners();
        done.complete();
      }
    }());
    return done.future;
  }

  Future<void> _serve(HttpRequest request) async {
    final response = request.response;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    response.headers.set('X-Content-Type-Options', 'nosniff');
    response.headers.set(
      'Content-Security-Policy',
      "default-src 'self'; script-src 'self' 'unsafe-inline'; "
          "connect-src 'self'; style-src 'self' 'unsafe-inline'; "
          "object-src 'none'; base-uri 'none'",
    );
    if (!request.uri.path.startsWith('/$_token/')) {
      response.statusCode = HttpStatus.notFound;
    } else {
      final path = request.uri.path.substring(_token.length + 2);
      if (path == 'activation' && request.method == 'POST') {
        response.headers.contentType = ContentType.json;
        final bytes = <int>[];
        await for (final chunk in request) {
          bytes.addAll(chunk);
          if (bytes.length > 8192) {
            response.statusCode = HttpStatus.requestEntityTooLarge;
            await response.close();
            return;
          }
        }
        try {
          final report = jsonDecode(utf8.decode(bytes)) as Map;
          final current =
              report['revision'] == _pendingRevision &&
              _pendingJavascript != null &&
              _pendingRevision == _digest(_sources());
          if (current) {
            if (report['ok'] == true) {
              _javascript = _pendingJavascript;
              revision = _pendingRevision;
              activations++;
              lastCheck = {
                ...?lastCheck,
                'ok': true,
                'runtimeSmokePassed': true,
                'activation': 'visible',
                'functionalBehaviorVerified': false,
              };
            } else {
              _failedRevision = _pendingRevision;
              lastCheck = {
                ...?lastCheck,
                'ok': false,
                'error': 'product_runtime_smoke_failed',
                'runtimeError': report['error'],
                'workingVersionRetained': _javascript != null,
              };
            }
            _pendingJavascript = null;
            _pendingRevision = null;
            notifyListeners();
          }
          response.write(jsonEncode({'ok': current && report['ok'] == true}));
        } on Object {
          response.statusCode = HttpStatus.badRequest;
        }
        await response.close();
        return;
      }
      if (request.method != 'GET') {
        response.statusCode = HttpStatus.methodNotAllowed;
        await response.close();
        return;
      }
      switch (path) {
        case '':
          response.headers.contentType = ContentType.html;
          response.write(_viewer);
        case 'frame':
          final requested = request.uri.queryParameters['revision'];
          if (requested != revision && requested != _pendingRevision) {
            response.statusCode = HttpStatus.notFound;
            break;
          }
          response.headers.contentType = ContentType.html;
          response.write('''
<!doctype html><meta charset="utf-8"><style>$_productStyle</style>
<main id="app"></main>
<script>window.productError=null;addEventListener('error',e=>window.productError=String(e.message));addEventListener('unhandledrejection',e=>window.productError=String(e.reason));</script>
<script src="main.js?revision=$requested"></script>''');
        case 'main.js':
          response.headers.contentType = ContentType(
            'application',
            'javascript',
          );
          final requested = request.uri.queryParameters['revision'];
          if (requested == revision) {
            response.write(_javascript ?? '');
          } else if (requested == _pendingRevision) {
            response.write(_pendingJavascript ?? '');
          } else {
            response.statusCode = HttpStatus.notFound;
          }
        case 'state':
          response.headers.contentType = ContentType.json;
          response.write(
            jsonEncode({'revision': revision, 'pending': _pendingRevision}),
          );
        case 'revision':
          response.headers.contentType = ContentType.text;
          response.write(revision ?? '');
        default:
          response.statusCode = HttpStatus.notFound;
      }
    }
    await response.close();
  }

  static const _productStyle =
      'body{font:17px system-ui;margin:0;color:#24332c;background:#f5f3ec} '
      'button,select,input{font:inherit;margin:8px;padding:8px} '
      'li{padding:12px;border-bottom:1px solid #ccc}';

  // The host viewer runs outside the product frame. It keeps the last visible
  // frame until the new frame loads without an uncaught error. This bounded
  // startup smoke is not behavioral acceptance or a security sandbox.
  static const _viewer = '''
<!doctype html><meta charset="utf-8"><title>Task board</title>
<style>body{font:17px system-ui;margin:40px;max-width:760px;color:#24332c;background:#f5f3ec}header{font-size:12px;color:#64756b}iframe{border:0;width:100%;min-height:650px;margin-top:16px}#status{font-size:13px}</style>
<header>LIVE PRODUCT · <span id="revision">building</span></header>
<p id="status">Building product…</p><section id="product"></section>
<script>
let active=null,visible=null,testing=null;
async function tick(){
  try{
    const state=await(await fetch('state')).json();
    const target=state.pending||state.revision;
    if(!target||target===visible||target===testing)return;
    testing=target;
    const frame=document.createElement('iframe');
    frame.title='Running task board';frame.style.display='none';
    let finished=false;
    const fail=async(error)=>{
      if(finished)return;finished=true;
      if(state.pending===target)await fetch('activation',{method:'POST',body:JSON.stringify({revision:target,ok:false,error:String(error).slice(0,500)})});
      frame.remove();testing=null;
      document.getElementById('status').textContent='Candidate failed · working version retained';
    };
    const timeout=setTimeout(()=>fail('product load timed out'),10000);
    frame.onload=()=>requestAnimationFrame(()=>requestAnimationFrame(async()=>{
      try{
        if(finished)return;
        const error=frame.contentWindow.productError;
        if(error)throw Error(error);
        if(!frame.contentDocument.getElementById('app')?.children.length)throw Error('product rendered no content');
        if(state.pending===target){
          const result=await(await fetch('activation',{method:'POST',body:JSON.stringify({revision:target,ok:true})})).json();
          if(!result.ok)throw Error('stale product activation');
        }
        finished=true;clearTimeout(timeout);
        if(active)active.remove();active=frame;visible=target;testing=null;
        frame.style.display='block';document.getElementById('status').textContent='';
        document.getElementById('revision').textContent=target.slice(0,10);
      }catch(e){clearTimeout(timeout);await fail(e)}
    }));
    frame.src='frame?revision='+encodeURIComponent(target);
    document.getElementById('product').append(frame);
  }catch(e){}
}
tick();setInterval(tick,700);
</script>''';

  Future<void> close() async {
    _debounce?.cancel();
    await _watch?.cancel();
    await _building;
    await _server?.close(force: true);
    _server = null;
  }
}
