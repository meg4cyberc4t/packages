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
    referenceDescription('blend_normal_sRGB'),
    () => expectBrowserReference('blend_normal_sRGB'),
  );
  test(
    referenceDescription('blend_normal_linearRGB'),
    () => expectBrowserReference('blend_normal_linearRGB'),
  );
  test(
    referenceDescription('blend_multiply_sRGB'),
    () => expectBrowserReference('blend_multiply_sRGB'),
  );
  test(
    referenceDescription('blend_multiply_linearRGB'),
    () => expectBrowserReference('blend_multiply_linearRGB'),
  );
  test(
    referenceDescription('blend_screen_sRGB'),
    () => expectBrowserReference('blend_screen_sRGB'),
  );
  test(
    referenceDescription('blend_screen_linearRGB'),
    () => expectBrowserReference('blend_screen_linearRGB'),
  );
  test(
    referenceDescription('blend_darken_sRGB'),
    () => expectBrowserReference('blend_darken_sRGB'),
  );
  test(
    referenceDescription('blend_darken_linearRGB'),
    () => expectBrowserReference('blend_darken_linearRGB'),
  );
  test(
    referenceDescription('blend_lighten_sRGB'),
    () => expectBrowserReference('blend_lighten_sRGB'),
  );
  test(
    referenceDescription('blend_lighten_linearRGB'),
    () => expectBrowserReference('blend_lighten_linearRGB'),
  );
  test(
    referenceDescription('blend_overlay_sRGB'),
    () => expectBrowserReference('blend_overlay_sRGB'),
  );
  test(
    referenceDescription('blend_overlay_linearRGB'),
    () => expectBrowserReference('blend_overlay_linearRGB'),
  );
  test(
    referenceDescription('blend_color-dodge_sRGB'),
    () => expectBrowserReference('blend_color-dodge_sRGB'),
  );
  test(
    referenceDescription('blend_color-dodge_linearRGB'),
    () => expectBrowserReference('blend_color-dodge_linearRGB'),
  );
  test(
    referenceDescription('blend_color-burn_sRGB'),
    () => expectBrowserReference('blend_color-burn_sRGB'),
  );
  test(
    referenceDescription('blend_color-burn_linearRGB'),
    () => expectBrowserReference('blend_color-burn_linearRGB'),
  );
  test(
    referenceDescription('blend_hard-light_sRGB'),
    () => expectBrowserReference('blend_hard-light_sRGB'),
  );
  test(
    referenceDescription('blend_hard-light_linearRGB'),
    () => expectBrowserReference('blend_hard-light_linearRGB'),
  );
  test(
    referenceDescription('blend_soft-light_sRGB'),
    () => expectBrowserReference('blend_soft-light_sRGB'),
  );
  test(
    referenceDescription('blend_soft-light_linearRGB'),
    () => expectBrowserReference('blend_soft-light_linearRGB'),
  );
  test(
    referenceDescription('blend_difference_sRGB'),
    () => expectBrowserReference('blend_difference_sRGB'),
  );
  test(
    referenceDescription('blend_difference_linearRGB'),
    () => expectBrowserReference('blend_difference_linearRGB'),
  );
  test(
    referenceDescription('blend_exclusion_sRGB'),
    () => expectBrowserReference('blend_exclusion_sRGB'),
  );
  test(
    referenceDescription('blend_exclusion_linearRGB'),
    () => expectBrowserReference('blend_exclusion_linearRGB'),
  );
  test(referenceDescription('blend_hue_sRGB'), () => expectBrowserReference('blend_hue_sRGB'));
  test(
    referenceDescription('blend_hue_linearRGB'),
    () => expectBrowserReference('blend_hue_linearRGB'),
  );
  test(
    referenceDescription('blend_saturation_sRGB'),
    () => expectBrowserReference('blend_saturation_sRGB'),
  );
  test(
    referenceDescription('blend_saturation_linearRGB'),
    () => expectBrowserReference('blend_saturation_linearRGB'),
  );
  test(referenceDescription('blend_color_sRGB'), () => expectBrowserReference('blend_color_sRGB'));
  test(
    referenceDescription('blend_color_linearRGB'),
    () => expectBrowserReference('blend_color_linearRGB'),
  );
  test(
    referenceDescription('blend_luminosity_sRGB'),
    () => expectBrowserReference('blend_luminosity_sRGB'),
  );
  test(
    referenceDescription('blend_luminosity_linearRGB'),
    () => expectBrowserReference('blend_luminosity_linearRGB'),
  );
  test(referenceDescription('blend_defaults'), () => expectBrowserReference('blend_defaults'));
  test(referenceDescription('blend_default_in'), () => expectBrowserReference('blend_default_in'));
  test(
    referenceDescription('blend_default_in2'),
    () => expectBrowserReference('blend_default_in2'),
  );
  test(
    referenceDescription('blend_source_alpha'),
    () => expectBrowserReference('blend_source_alpha'),
  );
  test(
    referenceDescription('blend_unknown_inputs'),
    () => expectBrowserReference('blend_unknown_inputs'),
  );
  test(referenceDescription('blend_subregion'), () => expectBrowserReference('blend_subregion'));
  test(referenceDescription('blend_chain'), () => expectBrowserReference('blend_chain'));

  for (final mode in <String>[
    'normal',
    'multiply',
    'screen',
    'darken',
    'lighten',
    'overlay',
    'color-dodge',
    'color-burn',
    'hard-light',
    'soft-light',
    'difference',
    'exclusion',
  ]) {
    for (final (int source, int backdrop) in <(int, int)>[
      (0, 0),
      (255, 255),
      (0, 255),
      (255, 0),
      (128, 64),
      (64, 160),
      (192, 96),
    ]) {
      test('independent $mode channel formula $source/$backdrop', () async {
        final double s = source / 255, b = backdrop / 255;
        final double d = b <= .25 ? ((16 * b - 12) * b + 4) * b : math.sqrt(b);
        final double expected = switch (mode) {
          'normal' => s,
          'multiply' => s * b,
          'screen' => s + b - s * b,
          'darken' => math.min(s, b),
          'lighten' => math.max(s, b),
          'overlay' => b <= .5 ? 2 * s * b : 1 - 2 * (1 - s) * (1 - b),
          'color-dodge' =>
            b == 0
                ? 0
                : s == 1
                ? 1
                : math.min(1, b / (1 - s)),
          'color-burn' =>
            b == 1
                ? 1
                : s == 0
                ? 0
                : 1 - math.min(1, (1 - b) / s),
          'hard-light' => s <= .5 ? 2 * s * b : 1 - 2 * (1 - s) * (1 - b),
          'soft-light' => s <= .5 ? b - (1 - 2 * s) * b * (1 - b) : b + (2 * s - 1) * (d - b),
          'difference' => (b - s).abs(),
          'exclusion' => b + s - 2 * b * s,
          _ => throw StateError(mode),
        };
        final ui.Image image = await renderSvg(
          filterSvg(
            '<feFlood flood-color="rgb($source,$source,$source)" result="s"/><feFlood flood-color="rgb($backdrop,$backdrop,$backdrop)" result="b"/><feBlend in="s" in2="b" mode="$mode"/>',
          ),
        );
        final Uint8List data = await pixels(image);
        image.dispose();
        for (var c = 0; c < 3; c++) {
          expect(data[c], closeTo(expected * 255, 2));
        }
        expect(data[3], 255);
      });
    }
  }
  for (final opacity in <String>['0', '1']) {
    test('transparent source/backdrop preserves other image $opacity', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feFlood flood-color="red" flood-opacity="$opacity" result="s"/><feFlood flood-color="blue" flood-opacity="${opacity == '0' ? '1' : '0'}" result="b"/><feBlend in="s" in2="b" mode="multiply"/>',
        ),
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      expect(data.sublist(0, 4), opacity == '0' ? <int>[0, 0, 255, 255] : <int>[255, 0, 0, 255]);
    });
  }
  test('unknown blend mode is diagnosed', () async {
    await expectLater(renderSvg(filterSvg('<feBlend mode="wrong"/>')), throwsA(anything));
  });
}
