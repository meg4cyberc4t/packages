// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics/src/filters/filter_shaders.dart';
import 'package:vector_graphics/src/filters/float_texture.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() => runFilterBackendTests();

/// The same checks run in flutter_tester, Chrome, and a native integration host.
void runFilterBackendTests({String shaderPrefix = ''}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  FilterShaders.debugAssetPrefix = shaderPrefix;
  test('float textures preserve every finite IEEE byte pattern used by parameters', () async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final context = FilterContext(
      VectorFilter('filter', const <String, String>{}),
      recorder.endRecording(),
      const ui.Rect.fromLTWH(0, 0, 128, 128),
      const ui.Size(128, 128),
    );
    final values = <double>[
      0,
      -0.0,
      -1,
      1,
      .1,
      3.141592653589793,
      -12345.678,
      1e-20,
      1e20,
      for (var byte = 0; byte < 256; byte++)
        (ByteData(4)..setUint32(0, 0x3f000000 | byte << 16 | byte << 8 | byte)).getFloat32(0),
    ];
    final ui.Image image = floatTexture(context, <List<double>>[values]);
    final Uint8List actual = (await image.toByteData())!.buffer.asUint8List();
    for (var i = 0; i < values.length; i++) {
      final bytes = ByteData(4)..setFloat32(0, values[i]);
      expect(actual.sublist(i * 8, i * 8 + 8), <int>[
        bytes.getUint8(0),
        bytes.getUint8(1),
        bytes.getUint8(2),
        255,
        bytes.getUint8(3),
        0,
        0,
        255,
      ], reason: 'parameter ${values[i]}');
    }
    context.dispose();
  });

  for (final (String operation, List<int> expected) in <(String, List<int>)>[
    (
      '<feComponentTransfer><feFuncR type="table" tableValues="-1 2"/></feComponentTransfer>',
      <int>[129, 128, 128, 255],
    ),
    (
      '<feConvolveMatrix order="1" kernelMatrix="-1" divisor="1" bias="1" preserveAlpha="true"/>',
      <int>[127, 127, 127, 255],
    ),
    (
      '<feConvolveMatrix order="1" kernelMatrix=".125" divisor="1" preserveAlpha="true"/>',
      <int>[16, 16, 16, 255],
    ),
  ]) {
    test('shader reads signed float parameters: $operation', () async {
      final Uint8List bytes = encodeSvg(
        xml:
            '<svg width="32" height="32"><defs><filter id="f" '
            'filterUnits="userSpaceOnUse" x="0" y="0" width="32" height="32" color-interpolation-filters="sRGB">'
            '$operation</filter></defs><rect width="32" height="32" fill="#808080" filter="url(#f)"/></svg>',
        debugName: 'backend parameters',
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      );
      final PictureInfo info = await decodeVectorGraphics(
        bytes.buffer.asByteData(),
        locale: null,
        textDirection: ui.TextDirection.ltr,
        clipViewbox: true,
        loader: const AssetBytesLoader('backend'),
      );
      final ui.Image image = await info.picture.toImage(32, 32);
      info.picture.dispose();
      final Uint8List pixels = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      for (var channel = 0; channel < 4; channel++) {
        expect(pixels[(16 * 32 + 16) * 4 + channel], closeTo(expected[channel], 1));
      }
    });
  }
}
