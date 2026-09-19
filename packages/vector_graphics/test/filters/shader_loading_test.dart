// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_shaders.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';

void main() {
  test('shader dependencies include only programs required by a mixed graph', () {
    final filters = <VectorFilter>[
      VectorFilter('filter', const <String, String>{}, <VectorFilter>[
        VectorFilter('feOffset', const <String, String>{}),
        VectorFilter('feGaussianBlur', const <String, String>{}),
        VectorFilter('feComposite', const <String, String>{'operator': 'over'}),
        VectorFilter('feMorphology', const <String, String>{'radius': '2 3'}),
        VectorFilter('feComponentTransfer', const <String, String>{}),
      ]),
    ];
    expect(FilterShaders.requiredBy(filters), isEmpty);
    expect(
      FilterShaders.requiredBy(<VectorFilter>[
        VectorFilter('filter', const <String, String>{}, <VectorFilter>[
          VectorFilter('feComposite', const <String, String>{'operator': 'arithmetic'}),
          VectorFilter('feMorphology', const <String, String>{'radius': '0 2'}),
          VectorFilter('feConvolveMatrix', const <String, String>{}),
          VectorFilter('feConvolveMatrix', const <String, String>{}),
        ]),
      ]),
      <String>{'composite', 'morphology_axis', 'convolve_matrix'},
    );
  });

  testWidgets('native filter works with every shader asset unavailable', (
    WidgetTester tester,
  ) async {
    final String previous = FilterShaders.debugAssetPrefix;
    FilterShaders.debugAssetPrefix = 'unavailable-filter-assets/';
    addTearDown(() => FilterShaders.debugAssetPrefix = previous);
    final Uint8List data = encodeSvg(
      xml: filterSvg('<feOffset dx="4"/>'),
      debugName: 'native only',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    final PictureInfo info = (await tester.runAsync(
      () => decodeVectorGraphics(
        data.buffer.asByteData(),
        locale: null,
        textDirection: TextDirection.ltr,
        clipViewbox: true,
        loader: _Loader(data.buffer.asByteData()),
      ),
    ))!;
    final ui.Image image = (await tester.runAsync(() => info.picture.toImage(128, 128)))!;
    info.picture.dispose();
    final Uint8List bytes = (await tester.runAsync(() => image.toByteData()))!.buffer.asUint8List();
    image.dispose();
    expect(bytes[(40 * 128 + 40) * 4 + 3], 255);
  });
}

class _Loader extends BytesLoader {
  const _Loader(this.data);
  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async => data;
}
