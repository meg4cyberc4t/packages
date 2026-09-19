// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(referenceDescription('shadow_defaults'), () => expectBrowserReference('shadow_defaults'));
  test(referenceDescription('shadow_sharp'), () => expectBrowserReference('shadow_sharp'));
  test(
    referenceDescription('shadow_negative_offset'),
    () => expectBrowserReference('shadow_negative_offset'),
  );
  test(
    referenceDescription('shadow_horizontal'),
    () => expectBrowserReference('shadow_horizontal'),
  );
  test(referenceDescription('shadow_vertical'), () => expectBrowserReference('shadow_vertical'));
  test(
    referenceDescription('shadow_anisotropic'),
    () => expectBrowserReference('shadow_anisotropic'),
  );
  test(referenceDescription('shadow_colored'), () => expectBrowserReference('shadow_colored'));
  test(
    referenceDescription('shadow_transparent'),
    () => expectBrowserReference('shadow_transparent'),
  );
  test(referenceDescription('shadow_alpha'), () => expectBrowserReference('shadow_alpha'));
  test(referenceDescription('shadow_style'), () => expectBrowserReference('shadow_style'));
  test(referenceDescription('shadow_current'), () => expectBrowserReference('shadow_current'));
  test(
    referenceDescription('shadow_negative_blur'),
    () => expectBrowserReference('shadow_negative_blur'),
  );
  test(
    referenceDescription('shadow_zero_region'),
    () => expectBrowserReference('shadow_zero_region'),
  );
  test(referenceDescription('shadow_subregion'), () => expectBrowserReference('shadow_subregion'));
  test(
    referenceDescription('shadow_source_alpha'),
    () => expectBrowserReference('shadow_source_alpha'),
  );
  test(
    referenceDescription('shadow_fractional'),
    () => expectBrowserReference('shadow_fractional'),
  );
  test(referenceDescription('shadow_linear'), () => expectBrowserReference('shadow_linear'));
  test(referenceDescription('shadow_bbox'), () => expectBrowserReference('shadow_bbox'));
  test(referenceDescription('shadow_chain'), () => expectBrowserReference('shadow_chain'));
  test(
    referenceDescription('shadow_transformed'),
    () => expectBrowserReference('shadow_transformed'),
  );

  for (final (int dx, int dy) in <(int, int)>[
    (8, 0),
    (0, 8),
    (-8, 0),
    (0, -8),
    (8, 8),
    (-8, -8),
    (0, 0),
  ]) {
    test('sharp shadow is behind the source ($dx,$dy)', () async {
      final ui.Image image = await renderSvg(
        filterSvg('<feDropShadow stdDeviation="0" dx="$dx" dy="$dy" flood-color="blue"/>'),
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      for (var y = 20; y < 80; y++) {
        for (var x = 20; x < 80; x++) {
          final bool source = x >= 32 && x < 64 && y >= 32 && y < 64;
          final bool shadow = x >= 32 + dx && x < 64 + dx && y >= 32 + dy && y < 64 + dy;
          final expected = source
              ? <int>[255, 0, 0, 255]
              : shadow
              ? <int>[0, 0, 255, 255]
              : <int>[0, 0, 0, 0];
          final int p = (y * 128 + x) * 4;
          if (data[p + 3] != expected[3] ||
              (expected[3] != 0 && (data[p] != expected[0] || data[p + 2] != expected[2]))) {
            fail('Unexpected shadow pixel ($x,$y)');
          }
        }
      }
    });
  }
  for (final attribute in <String>['dx', 'dy', 'stdDeviation']) {
    for (final value in <String>['NaN', 'Infinity', 'bad', '1px', '1%']) {
      test('reject malformed shadow $attribute=$value', () async {
        await expectLater(
          renderSvg(filterSvg('<feDropShadow $attribute="$value"/>')),
          throwsA(anything),
        );
      });
    }
  }
  test('shadow opacity multiplies source alpha and color alpha', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feDropShadow stdDeviation="0" dx="40" dy="0" flood-color="rgba(0,0,255,.5)" flood-opacity=".5"/>',
        shape: '<rect x="32" y="32" width="32" height="32" fill="red" fill-opacity=".5"/>',
      ),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[(40 * 128 + 80) * 4 + 3], closeTo(32, 1));
    expect(data[(40 * 128 + 80) * 4 + 2], 255);
  });
}
