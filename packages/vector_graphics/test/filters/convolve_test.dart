// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    referenceDescription('convolve_identity_sRGB'),
    () => expectBrowserReference('convolve_identity_sRGB'),
  );
  test(
    referenceDescription('convolve_average_sRGB'),
    () => expectBrowserReference('convolve_average_sRGB'),
  );
  test(
    referenceDescription('convolve_sharpen_sRGB'),
    () => expectBrowserReference('convolve_sharpen_sRGB'),
  );
  test(
    referenceDescription('convolve_emboss_sRGB'),
    () => expectBrowserReference('convolve_emboss_sRGB'),
  );
  test(
    referenceDescription('convolve_edge_sRGB'),
    () => expectBrowserReference('convolve_edge_sRGB'),
  );
  test(
    referenceDescription('convolve_preserve_alpha_sRGB'),
    () => expectBrowserReference('convolve_preserve_alpha_sRGB'),
  );
  test(
    referenceDescription('convolve_preserve_bias_sRGB'),
    () => expectBrowserReference('convolve_preserve_bias_sRGB'),
  );
  test(
    referenceDescription('convolve_bias_sRGB'),
    () => expectBrowserReference('convolve_bias_sRGB'),
  );
  test(
    referenceDescription('convolve_negative_bias_sRGB'),
    () => expectBrowserReference('convolve_negative_bias_sRGB'),
  );
  test(
    referenceDescription('convolve_alpha_create_sRGB'),
    () => expectBrowserReference('convolve_alpha_create_sRGB'),
  );
  test(
    referenceDescription('convolve_horizontal_sRGB'),
    () => expectBrowserReference('convolve_horizontal_sRGB'),
  );
  test(
    referenceDescription('convolve_vertical_sRGB'),
    () => expectBrowserReference('convolve_vertical_sRGB'),
  );
  test(
    referenceDescription('convolve_asymmetric_sRGB'),
    () => expectBrowserReference('convolve_asymmetric_sRGB'),
  );
  test(
    referenceDescription('convolve_target_sRGB'),
    () => expectBrowserReference('convolve_target_sRGB'),
  );
  test(
    referenceDescription('convolve_negative_divisor_sRGB'),
    () => expectBrowserReference('convolve_negative_divisor_sRGB'),
  );
  test(
    referenceDescription('convolve_zero_divisor_sRGB'),
    () => expectBrowserReference('convolve_zero_divisor_sRGB'),
  );
  test(
    referenceDescription('convolve_subregion_sRGB'),
    () => expectBrowserReference('convolve_subregion_sRGB'),
  );
  test(
    referenceDescription('convolve_zero_region_sRGB'),
    () => expectBrowserReference('convolve_zero_region_sRGB'),
  );
  test(
    referenceDescription('convolve_crop_none_sRGB'),
    () => expectBrowserReference('convolve_crop_none_sRGB'),
  );
  test(
    referenceDescription('convolve_crop_duplicate_sRGB'),
    () => expectBrowserReference('convolve_crop_duplicate_sRGB'),
  );
  test(
    referenceDescription('convolve_crop_wrap_sRGB'),
    () => expectBrowserReference('convolve_crop_wrap_sRGB'),
  );
  test(
    referenceDescription('convolve_identity_linearRGB'),
    () => expectBrowserReference('convolve_identity_linearRGB'),
  );
  test(
    referenceDescription('convolve_average_linearRGB'),
    () => expectBrowserReference('convolve_average_linearRGB'),
  );
  test(
    referenceDescription('convolve_sharpen_linearRGB'),
    () => expectBrowserReference('convolve_sharpen_linearRGB'),
  );
  test(
    referenceDescription('convolve_emboss_linearRGB'),
    () => expectBrowserReference('convolve_emboss_linearRGB'),
  );
  test(
    referenceDescription('convolve_edge_linearRGB'),
    () => expectBrowserReference('convolve_edge_linearRGB'),
  );
  test(
    referenceDescription('convolve_preserve_alpha_linearRGB'),
    () => expectBrowserReference('convolve_preserve_alpha_linearRGB'),
  );
  test(
    referenceDescription('convolve_preserve_bias_linearRGB'),
    () => expectBrowserReference('convolve_preserve_bias_linearRGB'),
  );
  test(
    referenceDescription('convolve_bias_linearRGB'),
    () => expectBrowserReference('convolve_bias_linearRGB'),
  );
  test(
    referenceDescription('convolve_negative_bias_linearRGB'),
    () => expectBrowserReference('convolve_negative_bias_linearRGB'),
  );
  test(
    referenceDescription('convolve_alpha_create_linearRGB'),
    () => expectBrowserReference('convolve_alpha_create_linearRGB'),
  );
  test(
    referenceDescription('convolve_horizontal_linearRGB'),
    () => expectBrowserReference('convolve_horizontal_linearRGB'),
  );
  test(
    referenceDescription('convolve_vertical_linearRGB'),
    () => expectBrowserReference('convolve_vertical_linearRGB'),
  );
  test(
    referenceDescription('convolve_asymmetric_linearRGB'),
    () => expectBrowserReference('convolve_asymmetric_linearRGB'),
  );
  test(
    referenceDescription('convolve_target_linearRGB'),
    () => expectBrowserReference('convolve_target_linearRGB'),
  );
  test(
    referenceDescription('convolve_negative_divisor_linearRGB'),
    () => expectBrowserReference('convolve_negative_divisor_linearRGB'),
  );
  test(
    referenceDescription('convolve_zero_divisor_linearRGB'),
    () => expectBrowserReference('convolve_zero_divisor_linearRGB'),
  );
  test(
    referenceDescription('convolve_subregion_linearRGB'),
    () => expectBrowserReference('convolve_subregion_linearRGB'),
  );
  test(
    referenceDescription('convolve_zero_region_linearRGB'),
    () => expectBrowserReference('convolve_zero_region_linearRGB'),
  );
  test(
    referenceDescription('convolve_crop_none_linearRGB'),
    () => expectBrowserReference('convolve_crop_none_linearRGB'),
  );
  test(
    referenceDescription('convolve_crop_duplicate_linearRGB'),
    () => expectBrowserReference('convolve_crop_duplicate_linearRGB'),
  );
  test(
    referenceDescription('convolve_crop_wrap_linearRGB'),
    () => expectBrowserReference('convolve_crop_wrap_linearRGB'),
  );
  test(referenceDescription('convolve_units_4'), () => expectBrowserReference('convolve_units_4'));
  test(
    referenceDescription('convolve_units_4_8'),
    () => expectBrowserReference('convolve_units_4_8'),
  );
  test(referenceDescription('convolve_units_0'), () => expectBrowserReference('convolve_units_0'));
  test(
    referenceDescription('convolve_units_neg1'),
    () => expectBrowserReference('convolve_units_neg1'),
  );
  test(
    referenceDescription('convolve_units_0_4'),
    () => expectBrowserReference('convolve_units_0_4'),
  );
  test(
    referenceDescription('convolve_mismatch'),
    () => expectBrowserReference('convolve_mismatch'),
  );
  test(referenceDescription('convolve_missing'), () => expectBrowserReference('convolve_missing'));
  test(
    referenceDescription('convolve_fractional_order'),
    () => expectBrowserReference('convolve_fractional_order'),
  );
  test(
    referenceDescription('convolve_object_units'),
    () => expectBrowserReference('convolve_object_units'),
  );
  test(
    referenceDescription('convolve_transform'),
    () => expectBrowserReference('convolve_transform'),
  );
  test(referenceDescription('convolve_named'), () => expectBrowserReference('convolve_named'));
  test(referenceDescription('convolve_chain'), () => expectBrowserReference('convolve_chain'));

  test('bias generates pixels after an empty input is expanded', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feFlood width="0"/> <feConvolveMatrix order="1" kernelMatrix="0" bias=".5" '
        'x="0" y="0" width="128" height="128"/>',
      ),
    );
    final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
    image.dispose();
    expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 4), <int>[64, 64, 64, 128]);
  });
  for (final scale in <double>[1, 2, 3]) {
    for (final explicit in <bool>[false, true]) {
      test('kernel grid and output interpolation $scale $explicit', () async {
        final ui.Image image = await renderSvg(
          filterSvg(
            '<feConvolveMatrix order="3 1" kernelMatrix="1 1 1" ${explicit ? 'kernelUnitLength="4"' : ''}/>',
            shape: '<rect x="32" y="16" width="32" height="96" fill="red"/>',
          ),
          scale: scale,
        );
        final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
        for (int x = (20 * scale).round(); x < 44 * scale; x++) {
          final int expected = explicit
              ? ((((x + .5) / scale - 26) / 12).clamp(0, 1) * 255).round()
              : x < 32 * scale - 1
              ? 0
              : x < 32 * scale
              ? 85
              : x < 32 * scale + 1
              ? 170
              : 255;
          expect(
            data[((48 * scale).round() * image.width + x) * 4 + 3],
            closeTo(expected, 2),
            reason: '$x',
          );
        }
        image.dispose();
      });
    }
  }
  double toLinear(double v) =>
      v <= .04045 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  double toSrgb(double v) => v <= .0031308 ? 12.92 * v : 1.055 * math.pow(v, 1 / 2.4) - .055;
  for (final linear in <bool>[false, true]) {
    for (final preserve in <bool>[false, true]) {
      for (final edge in <String>['none', 'duplicate', 'wrap']) {
        for (final kernel in <List<double>>[
          <double>[1, 2, 3, 4, 5, 6, 7, 8, 9],
          <double>[0, -1, 0, -1, 5, -1, 0, -1, 0],
          <double>[0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]) {
          test('independent convolution $linear $preserve $edge $kernel', () async {
            final shape = StringBuffer();
            for (var y = 0; y < 8; y++) {
              for (var x = 0; x < 8; x++) {
                shape.write(
                  '<rect x="${48 + x}" y="${48 + y}" width="1" height="1" '
                  'fill="rgb(${x * 32},${y * 32},${(x + y) * 16})" fill-opacity="${(x + y) % 3 == 0 ? .5 : 1}"/>',
                );
              }
            }
            const crop = '<feOffset x="48" y="48" width="8" height="8"/>';
            final ui.Image original = await renderSvg(filterSvg(crop, shape: shape.toString()));
            final Uint8List source = (await original.toByteData())!.buffer.asUint8List();
            original.dispose();
            final ui.Image image = await renderSvg(
              filterSvg(
                '$crop <feConvolveMatrix kernelMatrix="${kernel.join(' ')}" edgeMode="$edge" '
                'preserveAlpha="$preserve" bias=".2" color-interpolation-filters="${linear ? 'linearRGB' : 'sRGB'}"/>',
                shape: shape.toString(),
              ),
            );
            final Uint8List actual = (await image.toByteData())!.buffer.asUint8List();
            image.dispose();
            List<double> read(int x, int y) {
              if (edge == 'wrap') {
                x %= 8;
                y %= 8;
              }
              if (edge == 'duplicate') {
                x = x.clamp(0, 7);
                y = y.clamp(0, 7);
              }
              if (x < 0 || y < 0 || x >= 8 || y >= 8) {
                return <double>[0, 0, 0, 0];
              }
              final int p = ((48 + y) * 128 + 48 + x) * 4;
              final double a = source[p + 3] / 255;
              return <double>[
                for (var ch = 0; ch < 3; ch++)
                  (linear ? toLinear(source[p + ch] / 255 / a) : source[p + ch] / 255 / a) *
                      (preserve ? 1 : a),
                a,
              ];
            }

            final double divisor = kernel.reduce((double a, double b) => a + b);
            for (var y = 0; y < 8; y++) {
              for (var x = 0; x < 8; x++) {
                final sums = <double>[0, 0, 0, 0];
                for (var row = 0; row < 3; row++) {
                  for (var col = 0; col < 3; col++) {
                    final List<double> v = read(x - 1 + col, y - 1 + row);
                    for (var ch = 0; ch < 4; ch++) {
                      sums[ch] +=
                          v[ch] * kernel[8 - (row * 3 + col)] / (divisor == 0 ? 1 : divisor);
                    }
                  }
                }
                final double a = preserve ? read(x, y)[3] : (sums[3] + .2).clamp(0, 1);
                final expected = <int>[
                  for (var ch = 0; ch < 3; ch++)
                    ((linear
                                ? toSrgb(
                                    preserve
                                        ? (sums[ch] + .2).clamp(0, 1)
                                        : a == 0
                                        ? 0
                                        : (sums[ch] + .2 * a).clamp(0, a) / a,
                                  )
                                : preserve
                                ? (sums[ch] + .2).clamp(0, 1)
                                : a == 0
                                ? 0
                                : (sums[ch] + .2 * a).clamp(0, a) / a) *
                            a *
                            255)
                        .round(),
                  (a * 255).round(),
                ];
                final int p = ((48 + y) * 128 + 48 + x) * 4;
                for (var ch = 0; ch < 4; ch++) {
                  expect(actual[p + ch], closeTo(expected[ch], 2), reason: '$x,$y channel $ch');
                }
              }
            }
          });
        }
      }
    }
  }
  for (final attr in <String>[
    'order="0"',
    'order="-1"',
    'order="1 2 3"',
    'order="65"',
    'order="NaN"',
    'kernelMatrix="NaN" order="1"',
    'kernelMatrix="1e100" order="1"',
    'targetX="-1"',
    'targetX="3"',
    'targetY="3"',
    'targetY=".5"',
    'divisor="NaN"',
    'divisor="1e100"',
    'divisor="1e-100"',
    'bias="Infinity"',
    'edgeMode="unknown"',
    'preserveAlpha="yes"',
    'kernelUnitLength="NaN"',
    'kernelUnitLength="1 2 3"',
    'kernelUnitLength="1e100"',
  ]) {
    test('invalid convolution attribute $attr', () async {
      final primitive = attr.contains('kernelMatrix')
          ? '<feConvolveMatrix $attr/>'
          : '<feConvolveMatrix kernelMatrix="0 0 0 0 1 0 0 0 0" $attr/>';
      await expectLater(
        renderSvg(filterSvg(primitive)),
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
  test('sample budget rejects excessive convolution work', () async {
    await expectLater(
      renderSvg(
        filterSvg(
          '<feConvolveMatrix order="64" '
          'kernelMatrix="${List<int>.filled(4096, 1).join(' ')}"/>',
        ),
        scale: 2,
      ),
      throwsA(
        isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('sample budget')),
      ),
    );
  });
}
