// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

String document(String ops, {String defs = ''}) =>
    '<svg width="128" height="128"><defs>$defs<filter id="f">$ops</filter></defs><rect width="32" height="32" filter="url(#f)"/></svg>';
Uint8List compile(String svg, {Map<String, Uint8List> sources = const <String, Uint8List>{}}) =>
    encodeSvg(
      xml: svg,
      debugName: 'feImage test',
      imageSources: sources,
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
Capture inspect(Uint8List bytes) {
  final capture = Capture();
  const codec = VectorGraphicsCodec();
  DecodeResponse? response;
  do {
    response = codec.decode(
      bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
      capture,
      response: response,
    );
  } while (!response.complete);
  return capture;
}

void main() {
  final raster = Uint8List.fromList(<int>[1, 2, 3]);
  for (final href in <String>['a.png', '../a.png', 'https://invalid/a.png']) {
    test('external raster embeds exact bytes: $href', () {
      final Capture capture = inspect(
        compile(document('<feImage href="$href"/>'), sources: <String, Uint8List>{href: raster}),
      );
      expect(capture.images.single.$1, ImageFormatTypes.filterRaster);
      expect(capture.images.single.$2, raster);
      expect(capture.filters.single.children.single.attributes['vector-image-id'], '0');
      expect(capture.filters.single.children.single.attributes.containsKey('href'), isFalse);
    });
  }
  test('duplicate href uses one resource and stable references', () {
    final Capture capture = inspect(
      compile(
        document('<feImage href="a"/><feImage href="a"/>'),
        sources: <String, Uint8List>{'a': raster},
      ),
    );
    expect(capture.images, hasLength(1));
    expect(
      capture.filters.single.children.map((VectorFilter f) => f.attributes['vector-image-id']),
      <String>['0', '0'],
    );
  });
  test('ordinary image and filter image do not collide', () {
    final String svg = document('<feImage href="a"/>').replaceFirst(
      '</svg>',
      '<image href="data:image/png;base64,AQID" width="16" height="16"/></svg>',
    );
    final Capture capture = inspect(compile(svg, sources: <String, Uint8List>{'a': raster}));
    expect(capture.images, hasLength(2));
    expect(capture.filters.single.children.single.attributes['vector-image-id'], '1');
  });
  for (final href in <String>[
    '',
    '#missing',
    'missing.png',
    'data:image/svg+xml,%3Csvg',
    'data:text/xml,%3Cother/%3E',
  ]) {
    test('missing resource removes forged internal attributes: $href', () {
      final Capture capture = inspect(
        compile(
          document('<feImage href="$href" vector-image-id="123" vector-image-fragment="true"/>'),
        ),
      );
      expect(capture.images, isEmpty);
      expect(
        capture.filters.single.children.single.attributes.containsKey('vector-image-id'),
        isFalse,
      );
      expect(
        capture.filters.single.children.single.attributes.containsKey('vector-image-fragment'),
        isFalse,
      );
    });
  }
  for (final attrs in <String>['href="a" xlink:href="b"', 'xlink:href="b" href="a"']) {
    test('href precedence: $attrs', () {
      final Capture capture = inspect(
        compile(
          document(
            '<feImage $attrs/>',
          ).replaceFirst('<svg ', '<svg xmlns:xlink="http://www.w3.org/1999/xlink" '),
          sources: <String, Uint8List>{'a': raster, 'b': Uint8List(1)},
        ),
      );
      expect(capture.images.single.$2, raster);
    });
  }
  test('standalone SVG compiles to nested vectors', () {
    final Capture capture = inspect(
      compile(
        document('<feImage href="a"/>'),
        sources: <String, Uint8List>{
          'a': Uint8List.fromList(
            utf8.encode('<svg width="32" height="16"><rect width="16" height="16"/></svg>'),
          ),
        },
      ),
    );
    expect(capture.images.single.$1, ImageFormatTypes.vector);
    final Capture nested = inspect(capture.images.single.$2);
    expect(nested.size, (32.0, 16.0));
    expect(capture.filters.single.children.single.attributes['vector-image-fragment'], 'false');
  });
  test('local fragments compile independently of forward order', () {
    final Capture capture = inspect(
      compile(
        document('<feImage href="#piece"/>', defs: '<rect id="piece" width="16" height="16"/>'),
      ),
    );
    expect(capture.images.single.$1, ImageFormatTypes.vector);
    expect(capture.filters.single.children.single.attributes['vector-image-fragment'], 'true');
  });
  test('circular filter graph is finite and ends in an invalid image', () {
    final Capture capture = inspect(
      compile(
        document(
          '<feImage href="#piece"/>',
          defs: '<rect id="piece" width="16" height="16" filter="url(#f)"/>',
        ),
      ),
    );
    final Capture nested = inspect(capture.images.single.$2);
    expect(nested.images, isEmpty);
    expect(
      nested.filters.single.children.single.attributes.containsKey('vector-image-id'),
      isFalse,
    );
  });
  for (final depth in <int>[1, 4, 8, 9]) {
    test('nested compilation depth $depth', () {
      final sources = <String, Uint8List>{
        for (var i = 0; i < depth; i++)
          '$i': Uint8List.fromList(
            utf8.encode(
              i == depth - 1
                  ? '<svg width="16" height="16"><rect width="16" height="16"/></svg>'
                  : document('<feImage href="${i + 1}"/>'),
            ),
          ),
      };
      if (depth > 8) {
        expect(() => compile(document('<feImage href="0"/>'), sources: sources), throwsStateError);
      } else {
        expect(compile(document('<feImage href="0"/>'), sources: sources), isNotEmpty);
      }
    });
  }
  test('encoded byte budget is checked before decoding', () {
    expect(
      () => compile(
        document('<feImage href="large"/>'),
        sources: <String, Uint8List>{'large': Uint8List(32 * 1024 * 1024 + 1)},
      ),
      throwsStateError,
    );
  });
  for (final count in <int>[256, 257]) {
    test('resource count budget $count', () {
      final String ops = List<String>.generate(count, (int i) => '<feImage href="$i"/>').join();
      if (count > 256) {
        expect(() => compile(document(ops)), throwsStateError);
      } else {
        expect(inspect(compile(document(ops))).images, isEmpty);
      }
    });
  }
}

class Capture extends VectorGraphicsCodecListener {
  @override
  void onEndFilter() {}
  final List<(int, Uint8List)> images = <(int, Uint8List)>[];
  final List<VectorFilter> filters = <VectorFilter>[];
  (double, double)? size;
  @override
  void onImage(int id, int format, Uint8List data, {VectorGraphicsErrorListener? onError}) {
    images.add((format, data));
  }

  @override
  void onBeginFilter(VectorFilter filter, Float64List transform, double width, double height) {
    filters.add(filter);
  }

  @override
  void onSize(double width, double height) {
    size = (width, height);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
