// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/turbulence.dart';
import 'helpers.dart';
import 'test_files.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    referenceDescription('turbulence_turbulence_sRGB_0_1'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_0_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_0_3'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_0_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_1_1'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_1_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_1_3'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_1_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_neg4_1'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_neg4_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_neg4_3'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_neg4_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_13p75_1'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_13p75_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_sRGB_13p75_3'),
    () => expectBrowserReference('turbulence_turbulence_sRGB_13p75_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_0_1'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_0_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_0_3'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_0_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_1_1'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_1_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_1_3'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_1_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_neg4_1'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_neg4_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_neg4_3'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_neg4_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_13p75_1'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_13p75_1'),
  );
  test(
    referenceDescription('turbulence_turbulence_linearRGB_13p75_3'),
    () => expectBrowserReference('turbulence_turbulence_linearRGB_13p75_3'),
  );
  test(
    referenceDescription('turbulence_turbulence_default'),
    () => expectBrowserReference('turbulence_turbulence_default'),
  );
  test(
    referenceDescription('turbulence_turbulence_zero_octaves'),
    () => expectBrowserReference('turbulence_turbulence_zero_octaves'),
  );
  test(
    referenceDescription('turbulence_turbulence_nine_octaves'),
    () => expectBrowserReference('turbulence_turbulence_nine_octaves'),
  );
  test(
    referenceDescription('turbulence_turbulence_one_axis'),
    () => expectBrowserReference('turbulence_turbulence_one_axis'),
  );
  test(
    referenceDescription('turbulence_turbulence_other_axis'),
    () => expectBrowserReference('turbulence_turbulence_other_axis'),
  );
  test(
    referenceDescription('turbulence_turbulence_stitch'),
    () => expectBrowserReference('turbulence_turbulence_stitch'),
  );
  test(
    referenceDescription('turbulence_turbulence_stitch_tiny'),
    () => expectBrowserReference('turbulence_turbulence_stitch_tiny'),
  );
  test(
    referenceDescription('turbulence_turbulence_subregion'),
    () => expectBrowserReference('turbulence_turbulence_subregion'),
  );
  test(
    referenceDescription('turbulence_turbulence_subregion_stitch'),
    () => expectBrowserReference('turbulence_turbulence_subregion_stitch'),
  );
  test(
    referenceDescription('turbulence_turbulence_clipped_stitch'),
    () => expectBrowserReference('turbulence_turbulence_clipped_stitch'),
  );
  test(
    referenceDescription('turbulence_turbulence_zero_region'),
    () => expectBrowserReference('turbulence_turbulence_zero_region'),
  );
  test(
    referenceDescription('turbulence_turbulence_tile'),
    () => expectBrowserReference('turbulence_turbulence_tile'),
  );
  test(
    referenceDescription('turbulence_turbulence_transform'),
    () => expectBrowserReference('turbulence_turbulence_transform'),
  );
  test(
    referenceDescription('turbulence_turbulence_bbox'),
    () => expectBrowserReference('turbulence_turbulence_bbox'),
  );
  test(
    referenceDescription('turbulence_turbulence_blend'),
    () => expectBrowserReference('turbulence_turbulence_blend'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_0_1'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_0_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_0_3'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_0_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_1_1'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_1_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_1_3'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_1_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_neg4_1'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_neg4_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_neg4_3'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_neg4_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_13p75_1'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_13p75_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_sRGB_13p75_3'),
    () => expectBrowserReference('turbulence_fractalNoise_sRGB_13p75_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_0_1'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_0_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_0_3'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_0_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_1_1'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_1_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_1_3'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_1_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_neg4_1'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_neg4_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_neg4_3'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_neg4_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_13p75_1'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_13p75_1'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_linearRGB_13p75_3'),
    () => expectBrowserReference('turbulence_fractalNoise_linearRGB_13p75_3'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_default'),
    () => expectBrowserReference('turbulence_fractalNoise_default'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_zero_octaves'),
    () => expectBrowserReference('turbulence_fractalNoise_zero_octaves'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_nine_octaves'),
    () => expectBrowserReference('turbulence_fractalNoise_nine_octaves'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_one_axis'),
    () => expectBrowserReference('turbulence_fractalNoise_one_axis'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_other_axis'),
    () => expectBrowserReference('turbulence_fractalNoise_other_axis'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_stitch'),
    () => expectBrowserReference('turbulence_fractalNoise_stitch'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_stitch_tiny'),
    () => expectBrowserReference('turbulence_fractalNoise_stitch_tiny'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_subregion'),
    () => expectBrowserReference('turbulence_fractalNoise_subregion'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_subregion_stitch'),
    () => expectBrowserReference('turbulence_fractalNoise_subregion_stitch'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_clipped_stitch'),
    () => expectBrowserReference('turbulence_fractalNoise_clipped_stitch'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_zero_region'),
    () => expectBrowserReference('turbulence_fractalNoise_zero_region'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_tile'),
    () => expectBrowserReference('turbulence_fractalNoise_tile'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_transform'),
    () => expectBrowserReference('turbulence_fractalNoise_transform'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_bbox'),
    () => expectBrowserReference('turbulence_fractalNoise_bbox'),
  );
  test(
    referenceDescription('turbulence_fractalNoise_blend'),
    () => expectBrowserReference('turbulence_fractalNoise_blend'),
  );

  test('Park-Miller 10000th value matches published sequence', () {
    final random = SvgNoiseRandom(1);
    var value = 0;
    for (var i = 0; i < 10000; i++) {
      value = random.next();
    }
    expect(value, 1043618065);
  });
  for (final pair in <(double, double)>[
    (0, 1),
    (-1, 2),
    (-4, 5),
    (13.99, 13),
    (-13.99, 14),
    (2147483647, 2147483646),
    (1e30, 2147483646),
    (-2147483646, 1),
  ]) {
    test('seed normalization ${pair.$1} -> ${pair.$2}', () {
      final a = SvgNoiseRandom(pair.$1), b = SvgNoiseRandom(pair.$2);
      expect(
        List<int>.generate(100, (int i) => a.next()),
        List<int>.generate(100, (int i) => b.next()),
      );
    });
  }
  for (final seed in <double>[0, 1, -4, 13, 42, 123456789]) {
    test('seed $seed creates a permutation and unit gradients', () {
      final List<List<double>> rows = turbulenceTables(seed);
      expect(rows[0].toSet(), List<double>.generate(256, (int i) => i.toDouble()).toSet());
      for (final List<double> row in rows.skip(1)) {
        for (var i = 0; i < row.length; i += 2) {
          final double length = row[i] * row[i] + row[i + 1] * row[i + 1];
          expect(length, anyOf(0, closeTo(1, 1e-12)));
        }
      }
    });
  }
  for (final f in <double>[0, .0001, .02, .07, .1, 1.5]) {
    for (final extent in <double>[1, 64, 128.5]) {
      test('stitch adjusts $f over $extent by minimum relative change', () {
        final double adjusted = stitchedFrequency(f, extent);
        expect(adjusted * extent, closeTo((adjusted * extent).round(), 1e-10));
        if (f == 0) {
          expect(adjusted, 0);
          return;
        }
        final double low = (f * extent).floor() / extent, high = (f * extent).ceil() / extent;
        expect(adjusted, low > 0 && f / low < high / f ? low : high);
      });
    }
  }
  for (final type in <String>['turbulence', 'fractalNoise']) {
    for (final space in <String>['sRGB', 'linearRGB']) {
      for (final reason in <String>['zero frequency', 'zero octaves']) {
        test('$type $space $reason has exact constant channels', () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feTurbulence type="$type" color-interpolation-filters="$space" ${reason == 'zero frequency' ? 'baseFrequency="0"' : 'baseFrequency=".1" numOctaves="0"'}/>',
            ),
          );
          final Uint8List data = await pixels(image);
          image.dispose();
          final expected = type == 'turbulence'
              ? <int>[0, 0, 0, 0]
              : space == 'sRGB'
              ? <int>[128, 128, 128, 128]
              : <int>[188, 188, 188, 128];
          for (var i = 0; i < data.length; i++) {
            expect(data[i], closeTo(expected[i % 4], 1));
          }
        });
      }
    }
  }
  for (final attrs in <String>[
    'baseFrequency="-1"',
    'baseFrequency=".1 -1"',
    'baseFrequency="NaN"',
    'baseFrequency="Infinity"',
    'baseFrequency="1e100"',
    'baseFrequency="1 2 3"',
    'baseFrequency=""',
    'numOctaves="-1"',
    'numOctaves="1.5"',
    'numOctaves="NaN"',
    'seed="NaN"',
    'seed="Infinity"',
    'type="bad"',
    'stitchTiles="bad"',
  ]) {
    test('invalid turbulence parameter $attrs', () async {
      await expectLater(
        renderSvg(filterSvg('<feTurbulence $attrs/>')),
        throwsA(
          isA<Object>().having(
            (Object e) => e.toString(),
            'diagnostic',
            contains('FormatException'),
          ),
        ),
      );
    });
  }
  test('octaves above output precision clamp to nine', () async {
    final ui.Image a = await renderSvg(
      filterSvg('<feTurbulence baseFrequency=".02" numOctaves="9"/>'),
    );
    final ui.Image b = await renderSvg(
      filterSvg('<feTurbulence baseFrequency=".02" numOctaves="100000000"/>'),
    );
    expect(await pixels(a), await pixels(b));
    a.dispose();
    b.dispose();
  });
  test('large noise evaluation fails before shader allocation', () async {
    await expectLater(
      renderSvg(
        filterSvg('<feTurbulence baseFrequency=".02" numOctaves="9"/>'),
        filterRasterScale: 32,
      ),
      throwsA(
        isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('sample budget')),
      ),
    );
  });

  final samples =
      jsonDecode(readTestString('test/filters/turbulence_samples.json')) as List<dynamic>;
  for (final seed in <double>[0, -4, 13.75, 42]) {
    for (final octaves in <int>[1, 3, 9]) {
      for (final fractal in <bool>[false, true]) {
        test('independent scalar noise oracle $seed $octaves $fractal', () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feTurbulence seed="$seed" numOctaves="$octaves" type="${fractal ? 'fractalNoise' : 'turbulence'}" baseFrequency=".07 .04"/>',
            ),
          );
          final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
          image.dispose();
          for (final dynamic sample in samples) {
            final row = sample as Map<String, dynamic>;
            if ((row['scale'] ?? 1) != 1 ||
                row['seed'] != seed ||
                row['octaves'] != octaves ||
                row['fractal'] != fractal) {
              continue;
            }
            final x = row['x'] as int, y = row['y'] as int;
            final rgba = row['rgba'] as List<dynamic>;
            final double alpha = (rgba[3] as num).toDouble();
            for (var c = 0; c < 4; c++) {
              final double expected = (rgba[c] as num).toDouble() * 255 * (c == 3 ? 1 : alpha);
              expect(data[(y * 128 + x) * 4 + c], closeTo(expected, 2), reason: '$x,$y channel $c');
            }
          }
        });
      }
    }
  }

  test('rare zero gradient is finite and preserves random sequence', () {
    final List<List<double>> rows = turbulenceTables(346);
    var found = false;
    for (final List<double> row in rows.skip(1)) {
      expect(row.every((double v) => v.isFinite), isTrue);
      for (var i = 0; i < row.length; i += 2) {
        found |= row[i] == 0 && row[i + 1] == 0;
      }
    }
    expect(found, isTrue);
  });
  for (final scale in <double>[.5, 2, 4]) {
    test('procedural detail and phase at scale $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feTurbulence seed="42" numOctaves="3" type="fractalNoise" baseFrequency=".07 .04"/>',
        ),
        scale: scale,
      );
      final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
      final int width = image.width;
      image.dispose();
      for (final dynamic sample in samples) {
        final row = sample as Map<String, dynamic>;
        if (row['scale'] != scale) {
          continue;
        }
        final x = row['x'] as int, y = row['y'] as int;
        final rgba = row['rgba'] as List<dynamic>;
        final double alpha = (rgba[3] as num).toDouble();
        for (var c = 0; c < 4; c++) {
          final double expected = (rgba[c] as num).toDouble() * 255 * (c == 3 ? 1 : alpha);
          expect(data[(y * width + x) * 4 + c], closeTo(expected, 2), reason: '$x,$y channel $c');
        }
      }
    });
  }
}
