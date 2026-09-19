// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg;

const String svgSource =
    '<svg width="32" height="32"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="32" height="32"><feImage href="photo"/></filter></defs><rect width="32" height="32" filter="url(#f)"/></svg>';
Map<String, Uint8List> source(String color) => <String, Uint8List>{
  'photo': Uint8List.fromList(
    utf8.encode('<svg width="32" height="32"><rect width="32" height="32" fill="$color"/></svg>'),
  ),
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => svg.cache.clear());
  for (final kind in <String>['string', 'bytes', 'file', 'asset', 'network']) {
    test('$kind loader includes resources in equality and cache key', () {
      final Map<String, Uint8List> a = source('red'), b = source('blue');
      final bytes = Uint8List.fromList(utf8.encode(svgSource));
      final file = File('never-opened.svg');
      vg.BytesLoader loader(Map<String, Uint8List> data) => switch (kind) {
        'string' => SvgStringLoader(svgSource, imageSources: data),
        'bytes' => SvgBytesLoader(bytes, imageSources: data),
        'file' => SvgFileLoader(file, imageSources: data),
        'asset' => SvgAssetLoader('never-opened.svg', imageSources: data),
        _ => SvgNetworkLoader('https://example.invalid/never-opened.svg', imageSources: data),
      };
      expect(loader(a), loader(a));
      expect(loader(a).hashCode, loader(a).hashCode);
      expect(loader(a), isNot(loader(b)));
      expect(loader(a).cacheKey(null), loader(a).cacheKey(null));
      expect(loader(a).cacheKey(null), isNot(loader(b).cacheKey(null)));
    });
  }
  test('same resource map reuses compiled bytes; new map invalidates', () async {
    final Map<String, Uint8List> a = source('red');
    final ByteData first = await SvgStringLoader(svgSource, imageSources: a).loadBytes(null);
    expect(
      identical(first, await SvgStringLoader(svgSource, imageSources: a).loadBytes(null)),
      isTrue,
    );
    final ByteData next = await SvgStringLoader(
      svgSource,
      imageSources: source('blue'),
    ).loadBytes(null);
    expect(identical(first, next), isFalse);
    expect(svg.cache.count, 2);
  });
  for (final color in <String>['red', 'blue']) {
    test('public loader renders supplied $color SVG', () async {
      final vg.PictureInfo info = await vg.vg.loadPicture(
        SvgStringLoader(svgSource, imageSources: source(color)),
        null,
      );
      final ui.Image image = await info.picture.toImage(32, 32);
      final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
      expect(
        data.sublist((16 * 32 + 16) * 4, (16 * 32 + 16) * 4 + 4),
        color == 'red' ? <int>[255, 0, 0, 255] : <int>[0, 0, 255, 255],
      );
      info.picture.dispose();
      image.dispose();
    });
  }
}
