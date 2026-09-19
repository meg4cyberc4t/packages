// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(referenceDescription('tile_source_sRGB'), () => expectBrowserReference('tile_source_sRGB'));
  test(referenceDescription('tile_crop_sRGB'), () => expectBrowserReference('tile_crop_sRGB'));
  test(referenceDescription('tile_alpha_sRGB'), () => expectBrowserReference('tile_alpha_sRGB'));
  test(referenceDescription('tile_named_sRGB'), () => expectBrowserReference('tile_named_sRGB'));
  test(
    referenceDescription('tile_unknown_sRGB'),
    () => expectBrowserReference('tile_unknown_sRGB'),
  );
  test(
    referenceDescription('tile_subregion_sRGB'),
    () => expectBrowserReference('tile_subregion_sRGB'),
  );
  test(
    referenceDescription('tile_transparent_sRGB'),
    () => expectBrowserReference('tile_transparent_sRGB'),
  );
  test(
    referenceDescription('tile_one_pixel_sRGB'),
    () => expectBrowserReference('tile_one_pixel_sRGB'),
  );
  test(
    referenceDescription('tile_zero_input_sRGB'),
    () => expectBrowserReference('tile_zero_input_sRGB'),
  );
  test(
    referenceDescription('tile_zero_output_sRGB'),
    () => expectBrowserReference('tile_zero_output_sRGB'),
  );
  test(referenceDescription('tile_chain_sRGB'), () => expectBrowserReference('tile_chain_sRGB'));
  test(
    referenceDescription('tile_source_linearRGB'),
    () => expectBrowserReference('tile_source_linearRGB'),
  );
  test(
    referenceDescription('tile_crop_linearRGB'),
    () => expectBrowserReference('tile_crop_linearRGB'),
  );
  test(
    referenceDescription('tile_alpha_linearRGB'),
    () => expectBrowserReference('tile_alpha_linearRGB'),
  );
  test(
    referenceDescription('tile_named_linearRGB'),
    () => expectBrowserReference('tile_named_linearRGB'),
  );
  test(
    referenceDescription('tile_unknown_linearRGB'),
    () => expectBrowserReference('tile_unknown_linearRGB'),
  );
  test(
    referenceDescription('tile_subregion_linearRGB'),
    () => expectBrowserReference('tile_subregion_linearRGB'),
  );
  test(
    referenceDescription('tile_transparent_linearRGB'),
    () => expectBrowserReference('tile_transparent_linearRGB'),
  );
  test(
    referenceDescription('tile_one_pixel_linearRGB'),
    () => expectBrowserReference('tile_one_pixel_linearRGB'),
  );
  test(
    referenceDescription('tile_zero_input_linearRGB'),
    () => expectBrowserReference('tile_zero_input_linearRGB'),
  );
  test(
    referenceDescription('tile_zero_output_linearRGB'),
    () => expectBrowserReference('tile_zero_output_linearRGB'),
  );
  test(
    referenceDescription('tile_chain_linearRGB'),
    () => expectBrowserReference('tile_chain_linearRGB'),
  );
  test(referenceDescription('tile_negative'), () => expectBrowserReference('tile_negative'));
  test(
    referenceDescription('tile_object_units'),
    () => expectBrowserReference('tile_object_units'),
  );
  test(referenceDescription('tile_transform'), () => expectBrowserReference('tile_transform'));
  test(
    referenceDescription('tile_repeat_repeat'),
    () => expectBrowserReference('tile_repeat_repeat'),
  );
  test(referenceDescription('tile_fractional'), () => expectBrowserReference('tile_fractional'));

  test('zero output remains transparent when input color space is unchanged', () async {
    final ui.Image image = await renderSvg(filterSvg('<feTile width="0"/>'));
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data.every((int value) => value == 0), isTrue);
  });
  for (final scale in <double>[.5, 1, 2, 3]) {
    for (final origin in <int>[-8, 0, 12]) {
      test('tile repeats transparent margins and origin $origin at $scale', () async {
        final ui.Image image = await renderSvg(
          filterSvg(
            '<feOffset x="$origin" y="0" width="16" height="16"/> <feTile/>',
            shape: '<rect x="${origin + 4}" y="4" width="8" height="8" fill="red"/>',
          ).replaceFirst(
            'x="0" y="0" width="128" height="128"',
            'x="-16" y="0" width="144" height="128"',
          ),
          scale: scale,
        );
        final Uint8List data = await pixels(image);
        for (var y = 1; y < 126; y += 2) {
          for (var x = 1; x < 126; x += 2) {
            final int dx = (x - origin) % 16;
            final int dy = y % 16;
            if (dx == 3 || dx == 11 || dy == 3 || dy == 11) {
              continue;
            }
            final int p = ((y * scale).floor() * image.width + (x * scale).floor()) * 4;
            final bool filled = dx >= 4 && dx < 12 && dy >= 4 && dy < 12;
            expect(data[p + 3], filled ? 255 : 0, reason: '$x,$y');
            if (filled) {
              expect(data.sublist(p, p + 3), <int>[255, 0, 0]);
            }
          }
        }
        image.dispose();
      });
    }
  }
  for (final attributes in <String>['width="-1"', 'x="NaN"', 'height="Infinity"']) {
    test('invalid tile region $attributes', () async {
      await expectLater(
        renderSvg(filterSvg('<feTile $attributes/>')),
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
  test('tile allocation obeys the shared texture limit', () async {
    await expectLater(
      renderSvg(filterSvg('<feTile/>'), filterRasterScale: 100),
      throwsA(isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('8192'))),
    );
  });
}
