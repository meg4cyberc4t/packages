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
    referenceDescription('displacement_fractional'),
    () => expectBrowserReference('displacement_fractional'),
  );
  test(
    referenceDescription('displacement_negative_fractional'),
    () => expectBrowserReference('displacement_negative_fractional'),
  );
  test(
    referenceDescription('displacement_gradient_sRGB'),
    () => expectBrowserReference('displacement_gradient_sRGB'),
  );
  test(
    referenceDescription('displacement_gradient_linearRGB'),
    () => expectBrowserReference('displacement_gradient_linearRGB'),
  );

  test('empty map is transparent black and displaces by minus half-scale', () async {
    final ui.Image image = await renderSvg(
      filterSvg('<feFlood width="0"/> <feDisplacementMap in="SourceGraphic" scale="16"/>'),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    for (final (int x, int y, int a) in <(int, int, int)>[
      (36, 48, 0),
      (42, 48, 255),
      (70, 48, 255),
      (74, 48, 0),
    ]) {
      expect(data[(y * 128 + x) * 4 + 3], a);
    }
  });

  test(
    referenceDescription('displacement_RR_sRGB'),
    () => expectBrowserReference('displacement_RR_sRGB'),
  );
  test(
    referenceDescription('displacement_RG_sRGB'),
    () => expectBrowserReference('displacement_RG_sRGB'),
  );
  test(
    referenceDescription('displacement_RB_sRGB'),
    () => expectBrowserReference('displacement_RB_sRGB'),
  );
  test(
    referenceDescription('displacement_RA_sRGB'),
    () => expectBrowserReference('displacement_RA_sRGB'),
  );
  test(
    referenceDescription('displacement_GR_sRGB'),
    () => expectBrowserReference('displacement_GR_sRGB'),
  );
  test(
    referenceDescription('displacement_GG_sRGB'),
    () => expectBrowserReference('displacement_GG_sRGB'),
  );
  test(
    referenceDescription('displacement_GB_sRGB'),
    () => expectBrowserReference('displacement_GB_sRGB'),
  );
  test(
    referenceDescription('displacement_GA_sRGB'),
    () => expectBrowserReference('displacement_GA_sRGB'),
  );
  test(
    referenceDescription('displacement_BR_sRGB'),
    () => expectBrowserReference('displacement_BR_sRGB'),
  );
  test(
    referenceDescription('displacement_BG_sRGB'),
    () => expectBrowserReference('displacement_BG_sRGB'),
  );
  test(
    referenceDescription('displacement_BB_sRGB'),
    () => expectBrowserReference('displacement_BB_sRGB'),
  );
  test(
    referenceDescription('displacement_BA_sRGB'),
    () => expectBrowserReference('displacement_BA_sRGB'),
  );
  test(
    referenceDescription('displacement_AR_sRGB'),
    () => expectBrowserReference('displacement_AR_sRGB'),
  );
  test(
    referenceDescription('displacement_AG_sRGB'),
    () => expectBrowserReference('displacement_AG_sRGB'),
  );
  test(
    referenceDescription('displacement_AB_sRGB'),
    () => expectBrowserReference('displacement_AB_sRGB'),
  );
  test(
    referenceDescription('displacement_AA_sRGB'),
    () => expectBrowserReference('displacement_AA_sRGB'),
  );
  test(
    referenceDescription('displacement_defaults_sRGB'),
    () => expectBrowserReference('displacement_defaults_sRGB'),
  );
  test(
    referenceDescription('displacement_alpha_defaults_sRGB'),
    () => expectBrowserReference('displacement_alpha_defaults_sRGB'),
  );
  test(
    referenceDescription('displacement_negative_sRGB'),
    () => expectBrowserReference('displacement_negative_sRGB'),
  );
  test(
    referenceDescription('displacement_transparent_map_sRGB'),
    () => expectBrowserReference('displacement_transparent_map_sRGB'),
  );
  test(
    referenceDescription('displacement_subregion_sRGB'),
    () => expectBrowserReference('displacement_subregion_sRGB'),
  );
  test(
    referenceDescription('displacement_cropped_input_sRGB'),
    () => expectBrowserReference('displacement_cropped_input_sRGB'),
  );
  test(
    referenceDescription('displacement_cropped_map_sRGB'),
    () => expectBrowserReference('displacement_cropped_map_sRGB'),
  );
  test(
    referenceDescription('displacement_unknown_sRGB'),
    () => expectBrowserReference('displacement_unknown_sRGB'),
  );
  test(
    referenceDescription('displacement_chain_sRGB'),
    () => expectBrowserReference('displacement_chain_sRGB'),
  );
  test(
    referenceDescription('displacement_zero_sRGB'),
    () => expectBrowserReference('displacement_zero_sRGB'),
  );
  test(
    referenceDescription('displacement_alpha_input_sRGB'),
    () => expectBrowserReference('displacement_alpha_input_sRGB'),
  );
  test(
    referenceDescription('displacement_RR_linearRGB'),
    () => expectBrowserReference('displacement_RR_linearRGB'),
  );
  test(
    referenceDescription('displacement_RG_linearRGB'),
    () => expectBrowserReference('displacement_RG_linearRGB'),
  );
  test(
    referenceDescription('displacement_RB_linearRGB'),
    () => expectBrowserReference('displacement_RB_linearRGB'),
  );
  test(
    referenceDescription('displacement_RA_linearRGB'),
    () => expectBrowserReference('displacement_RA_linearRGB'),
  );
  test(
    referenceDescription('displacement_GR_linearRGB'),
    () => expectBrowserReference('displacement_GR_linearRGB'),
  );
  test(
    referenceDescription('displacement_GG_linearRGB'),
    () => expectBrowserReference('displacement_GG_linearRGB'),
  );
  test(
    referenceDescription('displacement_GB_linearRGB'),
    () => expectBrowserReference('displacement_GB_linearRGB'),
  );
  test(
    referenceDescription('displacement_GA_linearRGB'),
    () => expectBrowserReference('displacement_GA_linearRGB'),
  );
  test(
    referenceDescription('displacement_BR_linearRGB'),
    () => expectBrowserReference('displacement_BR_linearRGB'),
  );
  test(
    referenceDescription('displacement_BG_linearRGB'),
    () => expectBrowserReference('displacement_BG_linearRGB'),
  );
  test(
    referenceDescription('displacement_BB_linearRGB'),
    () => expectBrowserReference('displacement_BB_linearRGB'),
  );
  test(
    referenceDescription('displacement_BA_linearRGB'),
    () => expectBrowserReference('displacement_BA_linearRGB'),
  );
  test(
    referenceDescription('displacement_AR_linearRGB'),
    () => expectBrowserReference('displacement_AR_linearRGB'),
  );
  test(
    referenceDescription('displacement_AG_linearRGB'),
    () => expectBrowserReference('displacement_AG_linearRGB'),
  );
  test(
    referenceDescription('displacement_AB_linearRGB'),
    () => expectBrowserReference('displacement_AB_linearRGB'),
  );
  test(
    referenceDescription('displacement_AA_linearRGB'),
    () => expectBrowserReference('displacement_AA_linearRGB'),
  );
  test(
    referenceDescription('displacement_defaults_linearRGB'),
    () => expectBrowserReference('displacement_defaults_linearRGB'),
  );
  test(
    referenceDescription('displacement_alpha_defaults_linearRGB'),
    () => expectBrowserReference('displacement_alpha_defaults_linearRGB'),
  );
  test(
    referenceDescription('displacement_negative_linearRGB'),
    () => expectBrowserReference('displacement_negative_linearRGB'),
  );
  test(
    referenceDescription('displacement_transparent_map_linearRGB'),
    () => expectBrowserReference('displacement_transparent_map_linearRGB'),
  );
  test(
    referenceDescription('displacement_subregion_linearRGB'),
    () => expectBrowserReference('displacement_subregion_linearRGB'),
  );
  test(
    referenceDescription('displacement_cropped_input_linearRGB'),
    () => expectBrowserReference('displacement_cropped_input_linearRGB'),
  );
  test(
    referenceDescription('displacement_cropped_map_linearRGB'),
    () => expectBrowserReference('displacement_cropped_map_linearRGB'),
  );
  test(
    referenceDescription('displacement_unknown_linearRGB'),
    () => expectBrowserReference('displacement_unknown_linearRGB'),
  );
  test(
    referenceDescription('displacement_chain_linearRGB'),
    () => expectBrowserReference('displacement_chain_linearRGB'),
  );
  test(
    referenceDescription('displacement_zero_linearRGB'),
    () => expectBrowserReference('displacement_zero_linearRGB'),
  );
  test(
    referenceDescription('displacement_alpha_input_linearRGB'),
    () => expectBrowserReference('displacement_alpha_input_linearRGB'),
  );
  test(
    referenceDescription('displacement_object_units'),
    () => expectBrowserReference('displacement_object_units'),
  );
  test(
    referenceDescription('displacement_transform'),
    () => expectBrowserReference('displacement_transform'),
  );
  test(
    referenceDescription('displacement_source_outside'),
    () => expectBrowserReference('displacement_source_outside'),
  );
  test(
    referenceDescription('displacement_empty_input'),
    () => expectBrowserReference('displacement_empty_input'),
  );
  test(
    referenceDescription('displacement_empty_map'),
    () => expectBrowserReference('displacement_empty_map'),
  );

  for (final linear in <bool>[false, true]) {
    for (final sx in <int>[0, 1, 2, 3]) {
      for (final sy in <int>[0, 1, 2, 3]) {
        for (final scale in <double>[-24, .5, 24]) {
          test('independent constant-map displacement $linear $sx $sy $scale', () async {
            final ui.Image image = await renderSvg(
              filterSvg(
                '<feFlood flood-color="#8040c0" flood-opacity=".5"/> '
                '<feDisplacementMap in="SourceGraphic" scale="$scale" '
                'xChannelSelector="${'RGBA'[sx]}" yChannelSelector="${'RGBA'[sy]}" '
                'color-interpolation-filters="${linear ? 'linearRGB' : 'sRGB'}"/>',
              ),
            );
            final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
            image.dispose();
            final channels = <double>[.5, .25, .75, 128 / 255];
            if (linear) {
              for (var i = 0; i < 3; i++) {
                channels[i] = math.pow((channels[i] + .055) / 1.055, 2.4).toDouble();
              }
            }
            final double dx = scale * (channels[sx] - .5);
            final double dy = scale * (channels[sy] - .5);
            for (var y = 16; y < 82; y++) {
              for (var x = 16; x < 82; x++) {
                final double coverage =
                    (x + dx - 31).clamp(0, 1) *
                    (64 - x - dx).clamp(0, 1) *
                    (y + dy - 31).clamp(0, 1) *
                    (64 - y - dy).clamp(0, 1);
                final int a = (coverage * 255).round();
                final int p = (y * 128 + x) * 4;
                expect(data[p], closeTo(a, 2), reason: '$x,$y red');
                expect(data[p + 3], closeTo(a, 2), reason: '$x,$y alpha');
                expect(data[p + 1], 0);
                expect(data[p + 2], 0);
              }
            }
          });
        }
      }
    }
  }
  for (final scale in <double>[.5, 1, 2, 3]) {
    test('sampling scale retains the displacement distance $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg('<feFlood/><feDisplacementMap in="SourceGraphic" scale="24"/>'),
        scale: scale,
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      // Opaque map alpha=1 moves the rectangle from 32..64 to 20..52.
      for (final (int x, int y, int a) in <(int, int, int)>[
        (18, 40, 0),
        (22, 40, 255),
        (50, 40, 255),
        (54, 40, 0),
      ]) {
        final int p = ((y * scale).floor() * (128 * scale).round() + (x * scale).floor()) * 4;
        expect(data[p + 3], a);
      }
    });
  }
  for (final color in <String>['sRGB', 'linearRGB']) {
    test('map color space does not change the source color $color', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feFlood flood-color="#808080"/><feDisplacementMap in="SourceGraphic" scale="12" '
          'color-interpolation-filters="$color" xChannelSelector="R" yChannelSelector="G"/>',
          shape: '<rect x="16" y="16" width="96" height="96" fill="#c06020" fill-opacity=".5"/>',
        ),
      );
      final Uint8List data = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 4), <int>[96, 48, 16, 128]);
    });
  }
  test('zero scale does not allocate a texture', () async {
    final ui.Image image = await renderSvg(
      filterSvg('<feDisplacementMap scale="0"/>'),
      filterRasterScale: 100,
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[(40 * 128 + 40) * 4 + 3], 255);
  });
  for (final attr in <String>[
    'scale="NaN"',
    'scale="Infinity"',
    'scale="1e100"',
    'scale="10%"',
    'scale="1px"',
    'xChannelSelector="r"',
    'xChannelSelector="X"',
    'yChannelSelector=""',
    'yChannelSelector="alpha"',
  ]) {
    test('invalid displacement parameter $attr', () async {
      await expectLater(
        renderSvg(filterSvg('<feDisplacementMap $attr/>')),
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
  test('displacement support region observes texture limits', () async {
    await expectLater(
      renderSvg(filterSvg('<feDisplacementMap scale="20000"/>')),
      throwsA(isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('8192'))),
    );
  });
}
