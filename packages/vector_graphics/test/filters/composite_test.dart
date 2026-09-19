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
    referenceDescription('composite_over_sRGB'),
    () => expectBrowserReference('composite_over_sRGB'),
  );
  test(
    referenceDescription('composite_over_linearRGB'),
    () => expectBrowserReference('composite_over_linearRGB'),
  );
  test(
    referenceDescription('composite_in_sRGB'),
    () => expectBrowserReference('composite_in_sRGB'),
  );
  test(
    referenceDescription('composite_in_linearRGB'),
    () => expectBrowserReference('composite_in_linearRGB'),
  );
  test(
    referenceDescription('composite_out_sRGB'),
    () => expectBrowserReference('composite_out_sRGB'),
  );
  test(
    referenceDescription('composite_out_linearRGB'),
    () => expectBrowserReference('composite_out_linearRGB'),
  );
  test(
    referenceDescription('composite_atop_sRGB'),
    () => expectBrowserReference('composite_atop_sRGB'),
  );
  test(
    referenceDescription('composite_atop_linearRGB'),
    () => expectBrowserReference('composite_atop_linearRGB'),
  );
  test(
    referenceDescription('composite_xor_sRGB'),
    () => expectBrowserReference('composite_xor_sRGB'),
  );
  test(
    referenceDescription('composite_xor_linearRGB'),
    () => expectBrowserReference('composite_xor_linearRGB'),
  );
  test(
    referenceDescription('composite_lighter_sRGB'),
    () => expectBrowserReference('composite_lighter_sRGB'),
  );
  test(
    referenceDescription('composite_lighter_linearRGB'),
    () => expectBrowserReference('composite_lighter_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_zero_sRGB'),
    () => expectBrowserReference('composite_arithmetic_zero_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_zero_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_zero_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_source_sRGB'),
    () => expectBrowserReference('composite_arithmetic_source_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_source_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_source_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_backdrop_sRGB'),
    () => expectBrowserReference('composite_arithmetic_backdrop_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_backdrop_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_backdrop_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_product_sRGB'),
    () => expectBrowserReference('composite_arithmetic_product_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_product_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_product_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_sum_sRGB'),
    () => expectBrowserReference('composite_arithmetic_sum_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_sum_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_sum_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_bias_sRGB'),
    () => expectBrowserReference('composite_arithmetic_bias_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_bias_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_bias_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_subtract_sRGB'),
    () => expectBrowserReference('composite_arithmetic_subtract_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_subtract_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_subtract_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_clamp_sRGB'),
    () => expectBrowserReference('composite_arithmetic_clamp_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_clamp_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_clamp_linearRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_all_sRGB'),
    () => expectBrowserReference('composite_arithmetic_all_sRGB'),
  );
  test(
    referenceDescription('composite_arithmetic_all_linearRGB'),
    () => expectBrowserReference('composite_arithmetic_all_linearRGB'),
  );
  test(
    referenceDescription('composite_default'),
    () => expectBrowserReference('composite_default'),
  );
  test(
    referenceDescription('composite_source_alpha'),
    () => expectBrowserReference('composite_source_alpha'),
  );
  test(
    referenceDescription('composite_subregion'),
    () => expectBrowserReference('composite_subregion'),
  );
  test(
    referenceDescription('composite_zero_region'),
    () => expectBrowserReference('composite_zero_region'),
  );
  test(referenceDescription('composite_chain'), () => expectBrowserReference('composite_chain'));

  const inputs =
      '<feFlood flood-color="red" flood-opacity=".5" result="s"/><feFlood flood-color="blue" flood-opacity=".25" result="b"/>';
  for (final (double k1, double k2, double k3, double k4) in <(double, double, double, double)>[
    (0, 0, 0, 0),
    (0, 1, 0, 0),
    (0, 0, 1, 0),
    (1, 0, 0, 0),
    (0, 1, 1, 0),
    (0, 1, -1, 0),
    (0, -1, 1, 0),
    (0, 0, 0, .25),
    (0, 0, 0, 2),
    (0, 0, 0, -1),
    (.5, .3, .2, .1),
    (4, 2, -1, .1),
  ]) {
    test('independent premultiplied arithmetic ($k1,$k2,$k3,$k4)', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '$inputs<feComposite in="s" in2="b" operator="arithmetic" k1="$k1" k2="$k2" k3="$k3" k4="$k4"/>',
        ),
      );
      final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      const double sa = 128 / 255, ba = 64 / 255;
      final s = <double>[sa, 0, 0, sa], b = <double>[0, 0, ba, ba];
      final expected = List<double>.generate(
        4,
        (int i) => (k1 * s[i] * b[i] + k2 * s[i] + k3 * b[i] + k4).clamp(0.0, 1.0),
      );
      for (var c = 0; c < 4; c++) {
        expect(
          data[c],
          closeTo(255 * (c < 3 ? math.min(expected[c], expected[3]) : expected[c]), 2),
        );
      }
    });
  }
  for (final op in <String>['over', 'in', 'out', 'atop', 'xor', 'lighter']) {
    test('independent Porter-Duff equation $op', () async {
      final ui.Image image = await renderSvg(
        filterSvg('$inputs<feComposite in="s" in2="b" operator="$op"/>'),
      );
      final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      const double sa = 128 / 255, ba = 64 / 255;
      final s = <double>[sa, 0, 0, sa], b = <double>[0, 0, ba, ba];
      for (var c = 0; c < 4; c++) {
        final double expected = switch (op) {
          'over' => s[c] + b[c] * (1 - sa),
          'in' => s[c] * ba,
          'out' => s[c] * (1 - ba),
          'atop' => s[c] * ba + b[c] * (1 - sa),
          'xor' => s[c] * (1 - ba) + b[c] * (1 - sa),
          'lighter' => math.min(1, s[c] + b[c]),
          _ => throw StateError(op),
        };
        expect(data[c], closeTo(expected * 255, 2));
      }
    });
  }
  for (final coefficient in <String>['k1', 'k2', 'k3', 'k4']) {
    for (final value in <String>['NaN', 'Infinity', '1e100', 'bad', '1 2']) {
      test('reject invalid arithmetic $coefficient=$value', () async {
        await expectLater(
          renderSvg(filterSvg('<feComposite operator="arithmetic" $coefficient="$value"/>')),
          throwsA(anything),
        );
      });
    }
  }
  for (final scale in <double>[1, 2, 3]) {
    test('arithmetic scale and transparent border $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feComposite in="SourceGraphic" in2="SourceGraphic" operator="arithmetic" k2="1"/>',
        ),
        scale: scale,
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      expect(
        data[((40 * scale).round() * (128 * scale).round() + (40 * scale).round()) * 4 + 3],
        255,
      );
      expect(
        data[((20 * scale).round() * (128 * scale).round() + (20 * scale).round()) * 4 + 3],
        0,
      );
    });
  }
  test('unknown operator is diagnosed', () async {
    await expectLater(renderSvg(filterSvg('<feComposite operator="wrong"/>')), throwsA(anything));
  });
}
