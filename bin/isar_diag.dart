import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void dumpPage(Uint8List bytes, int pageIndex, int pageSize) {
  final off = pageIndex * pageSize;
  if (off + pageSize > bytes.length) return;
  final page = bytes.sublist(off, off + pageSize);
  print('--- page $pageIndex ---');
  print('first 64 bytes: ' + page.sublist(0, 64).map((b) => b.toRadixString(16).padLeft(2,'0')).join(' '));
  print('u32 @0: 0x' + _u32(page,0).toRadixString(16));
  print('u32 @4: 0x' + _u32(page,4).toRadixString(16));
  print('u64 @pageEnd-8: 0x' + _u64(page,page.length-8).toRadixString(16));
}

int _u32(Uint8List b, int off) => b[off] | (b[off+1]<<8) | (b[off+2]<<16) | (b[off+3]<<24);
int _u64(Uint8List b, int off) {
  final low = _u32(b, off);
  final high = _u32(b, off+4);
  return (high<<32) | (low & 0xFFFFFFFF);
}

void main() {
  final dir = Directory('archive');
  for (final name in ['isar_3.isar','isar_4.isar']) {
    final f = File('archive/$name');
    if (!f.existsSync()) { print('$name not found'); continue; }
    final bytes = f.readAsBytesSync();
    print('File: $name size=${bytes.length}');
    const pageSize = 4096;
    final pages = (bytes.length / pageSize).floor();
    print('pages: $pages');
    for (var i=0;i<4 && i<pages;i++) dumpPage(bytes,i,pageSize);
    // also dump last two pages
    if (pages>2) dumpPage(bytes,pages-2,pageSize);
    if (pages>1) dumpPage(bytes,pages-1,pageSize);
  }
}


