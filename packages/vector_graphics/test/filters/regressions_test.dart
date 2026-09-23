// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML adjacency preserves SVG text whitespace.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics/src/filters/filter_executor.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';

Future<ui.Rect> paintedBounds(ui.Image image) async {
  final Uint8List data = await pixels(image);
  ui.Rect bounds = ui.Rect.zero;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (data[(y * image.width + x) * 4 + 3] == 0) {
        continue;
      }
      final rect = ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1);
      bounds = bounds.isEmpty ? rect : bounds.expandToInclude(rect);
    }
  }
  return bounds;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unpainted filtered geometry retains element opacity', () async {
    final ui.Image image = await renderSvg(
      '<svg width="128" height="128"><filter id="f"><feFlood flood-color="red"/></filter>'
      '<rect x="32" y="32" width="32" height="32" fill="none" opacity=".5" filter="url(#f)"/></svg>',
    );
    addTearDown(image.dispose);
    final Uint8List data = await pixels(image);
    expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 3), <int>[255, 0, 0]);
    expect(data[(40 * 128 + 40) * 4 + 3], closeTo(128, 1));
  });

  for (final anchor in <String>['middle', 'end']) {
    for (final layer in <String>[
      'opacity=".5"',
      'filter="url(#f)"',
      'clip-path="url(#c)"',
      'mask="url(#m)"',
    ]) {
      test('$anchor text anchoring spans $layer', () async {
        String svg(String text) =>
            '<svg width="128" height="128"><defs><filter id="f"><feOffset/></filter>'
            '<clipPath id="c"><rect width="128" height="128"/></clipPath>'
            '<mask id="m"><rect width="128" height="128" fill="white"/></mask></defs>'
            '<text x="100" y="70" font-size="12" text-anchor="$anchor">$text</text></svg>';
        final ui.Image actual = await renderSvg(svg('AA<tspan $layer>BB</tspan>CC'));
        final ui.Image expected = await renderSvg(svg('AABBCC'));
        addTearDown(actual.dispose);
        addTearDown(expected.dispose);
        expect(await paintedBounds(actual), await paintedBounds(expected));
      });
    }
  }

  for (final operation in <String>[
    'feGaussianBlur stdDeviation="4"',
    'feMorphology operator="dilate" radius="8"',
    'feMorphology operator="dilate" radius="8 0"',
    'feConvolveMatrix order="3 1" kernelMatrix="0 0 1" edgeMode="none"',
  ]) {
    for (final input in <String>['SourceGraphic', 'SourceAlpha', 'clipped']) {
      test('$operation samples $input across the output edge', () async {
        final prefix = input == 'clipped' ? '<feOffset result="clipped"/>' : '';
        final ui.Image image = await renderSvg(
          '<svg width="128" height="128"><filter id="f" filterUnits="userSpaceOnUse" '
          'x="32" y="0" width="64" height="128" color-interpolation-filters="sRGB">'
          '$prefix<$operation in="$input"/></filter>'
          '<rect x="16" y="32" width="16" height="32" fill="red" filter="url(#f)"/></svg>',
        );
        addTearDown(image.dispose);
        final Uint8List data = await pixels(image);
        expect(data[(40 * 128 + 32) * 4 + 3], input == 'clipped' ? isZero : greaterThan(20));
        expect(
          data[(40 * 128 + 31) * 4 + 3],
          0,
          reason: 'The output region still clips the effect.',
        );
      });
    }
  }

  for (final scale in <double>[1, 2]) {
    test('nested feImage filters preserve detail at placement scale $scale', () async {
      const contents =
          '<filter id="f" x="0" y="0" width="1" height="1" color-interpolation-filters="sRGB">'
          '<feComponentTransfer><feFuncR type="linear" slope=".5"/></feComponentTransfer></filter>'
          '<g filter="url(#f)"><rect width="16" height="16" fill="none"/>'
          '<path d="M 1 1 L 15 15" stroke="red" stroke-width=".15"/></g>';
      final href =
          'data:image/svg+xml;base64,${base64Encode(utf8.encode('<svg width="16" height="16">$contents</svg>'))}';
      final ui.Image actual = await renderSvg(
        '<svg width="128" height="128"><filter id="outer" x="0" y="0" width="1" height="1">'
        '<feImage href="$href"/></filter><rect width="128" height="128" filter="url(#outer)"/></svg>',
        scale: scale,
      );
      final ui.Image expected = await renderSvg(
        '<svg width="16" height="16">$contents</svg>',
        scale: scale,
        filterRasterScale: 8 * scale,
      );
      addTearDown(actual.dispose);
      addTearDown(expected.dispose);
      expect(await pixels(actual), await pixels(expected));
    });
  }

  test('linearRGB dilation preserves color when sampling outside the output', () async {
    String svg(int left) =>
        '<svg width="128" height="128">'
        '<filter id="f" filterUnits="userSpaceOnUse" x="$left" y="0" width="96" height="128" color-interpolation-filters="linearRGB">'
        '<feMorphology operator="dilate" radius="8"/></filter><g filter="url(#f)">'
        '<rect x="8" y="24" width="24" height="64" fill="#c06020"/>'
        '<rect x="28" y="40" width="32" height="64" fill="#2080c0" fill-opacity=".5"/></g></svg>';
    final ui.Image actual = await renderSvg(svg(32));
    final ui.Image full = await renderSvg(svg(0));
    addTearDown(actual.dispose);
    addTearDown(full.dispose);
    final Uint8List data = await pixels(actual);
    final Uint8List expected = await pixels(full);
    for (var y = 0; y < 128; y++) {
      for (var x = 32; x < 96; x++) {
        final int p = (y * 128 + x) * 4;
        expect(data.sublist(p, p + 4), expected.sublist(p, p + 4), reason: '$x,$y');
      }
    }
  });

  for (final operation in <String>['feMerge', 'feBlend', 'feComposite']) {
    test('repeated $operation inputs have bounded playback and preserve pixels', () async {
      final children = <VectorFilter>[
        VectorFilter('feFlood', const <String, String>{'flood-color-argb': '4294901760'}),
        for (var i = 0; i < 32; i++)
          VectorFilter(
            operation,
            <String, String>{
              'result': 'r$i',
              if (i > 0 && operation != 'feMerge') 'in2': 'r${i - 1}',
            },
            operation == 'feMerge'
                ? <VectorFilter>[
                    VectorFilter('feMergeNode', const <String, String>{}),
                    VectorFilter('feMergeNode', const <String, String>{}),
                  ]
                : const <VectorFilter>[],
          ),
      ];
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder);
      final context = FilterContext(
        VectorFilter('filter', const <String, String>{
          'x': '0',
          'y': '0',
          'width': '1',
          'height': '1',
          'color-interpolation-filters': 'sRGB',
        }, children),
        recorder.endRecording(),
        const ui.Rect.fromLTWH(0, 0, 16, 16),
        const ui.Size(16, 16),
      );
      addTearDown(context.dispose);
      final FilterImage result = executeFilter(context);
      expect(context.requiresRasterResolution, isTrue);
      expect(result.replayCost, lessThanOrEqualTo(128));
      final ui.Image image = await result.picture.toImage(16, 16);
      addTearDown(image.dispose);
      expect((await pixels(image)).sublist(0, 4), <int>[255, 0, 0, 255]);
    });
  }

  for (final nestedImage in <bool>[false, true]) {
    test('playback cost crosses nested filter boundaries, image=$nestedImage', () async {
      final String merges = List<String>.filled(
        4,
        '<feMerge><feMergeNode/><feMergeNode/></feMerge>',
      ).join();
      final filter = '<filter id="f" x="0" y="0" width="1" height="1">$merges</filter>';
      const rect = '<rect width="16" height="16" fill="red" filter="url(#f)"/>';
      final child = '<svg width="16" height="16">$filter$rect</svg>';
      final href = 'data:image/svg+xml;base64,${base64Encode(utf8.encode(child))}';
      final source = nestedImage
          ? '<filter id="outer" x="0" y="0" width="1" height="1"><feImage href="$href"/>$merges</filter><rect width="16" height="16" filter="url(#outer)"/>'
          : '$filter<g filter="url(#f)">$rect</g>';
      final Uint8List bytes = encodeSvg(
        xml: '<svg width="16" height="16">$source</svg>',
        debugName: 'nested filter replay',
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      );
      final PictureInfo info = await decodeVectorGraphics(
        bytes.buffer.asByteData(),
        locale: null,
        textDirection: ui.TextDirection.ltr,
        clipViewbox: true,
        loader: const AssetBytesLoader('nested filter replay'),
      );
      addTearDown(info.picture.dispose);
      expect(info.requiresRasterResolution, isTrue);
      final ui.Image image = await info.picture.toImage(16, 16);
      addTearDown(image.dispose);
      expect((await pixels(image)).sublist(0, 4), <int>[255, 0, 0, 255]);
    });
  }
}
