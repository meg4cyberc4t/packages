// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final op in <String>['erode', 'dilate']) {
    for (final horizontal in <bool>[false, true]) {
      for (final scale in <double>[1, 2, 3]) {
        test('one-axis $op coverage at scale $scale horizontal=$horizontal', () async {
          final radius = horizontal ? '4 0' : '0 4';
          final ui.Image image = await renderSvg(
            filterSvg('<feMorphology operator="$op" radius="$radius"/>'),
            scale: scale,
          );
          final Uint8List data = await pixels(image);
          final int size = image.width;
          image.dispose();
          final delta = op == 'dilate' ? 4 : -4;
          for (var y = 0; y < size; y++) {
            for (var x = 0; x < size; x++) {
              final bool inside =
                  x >= (32 - (horizontal ? delta : 0)) * scale &&
                  x < (64 + (horizontal ? delta : 0)) * scale &&
                  y >= (32 - (horizontal ? 0 : delta)) * scale &&
                  y < (64 + (horizontal ? 0 : delta)) * scale;
              if (data[(y * size + x) * 4 + 3] != (inside ? 255 : 0)) {
                fail('Unexpected one-axis pixel ($x,$y)');
              }
            }
          }
        });
      }
    }
  }
  test(
    referenceDescription('morphology_erode_zero'),
    () => expectBrowserReference('morphology_erode_zero'),
  );
  test(
    referenceDescription('morphology_erode_isotropic'),
    () => expectBrowserReference('morphology_erode_isotropic'),
  );
  test(
    referenceDescription('morphology_erode_anisotropic'),
    () => expectBrowserReference('morphology_erode_anisotropic'),
  );
  test(
    referenceDescription('morphology_erode_horizontal'),
    () => expectBrowserReference('morphology_erode_horizontal'),
  );
  test(
    referenceDescription('morphology_erode_vertical'),
    () => expectBrowserReference('morphology_erode_vertical'),
  );
  test(
    referenceDescription('morphology_erode_fractional'),
    () => expectBrowserReference('morphology_erode_fractional'),
  );
  test(
    referenceDescription('morphology_erode_negative'),
    () => expectBrowserReference('morphology_erode_negative'),
  );
  test(
    referenceDescription('morphology_erode_negative_axis'),
    () => expectBrowserReference('morphology_erode_negative_axis'),
  );
  test(
    referenceDescription('morphology_erode_large'),
    () => expectBrowserReference('morphology_erode_large'),
  );
  test(
    referenceDescription('morphology_erode_linear'),
    () => expectBrowserReference('morphology_erode_linear'),
  );
  test(
    referenceDescription('morphology_erode_edge'),
    () => expectBrowserReference('morphology_erode_edge'),
  );
  test(
    referenceDescription('morphology_erode_subregion'),
    () => expectBrowserReference('morphology_erode_subregion'),
  );
  test(
    referenceDescription('morphology_erode_source_alpha'),
    () => expectBrowserReference('morphology_erode_source_alpha'),
  );
  test(
    referenceDescription('morphology_erode_bbox'),
    () => expectBrowserReference('morphology_erode_bbox'),
  );
  test(
    referenceDescription('morphology_dilate_zero'),
    () => expectBrowserReference('morphology_dilate_zero'),
  );
  test(
    referenceDescription('morphology_dilate_isotropic'),
    () => expectBrowserReference('morphology_dilate_isotropic'),
  );
  test(
    referenceDescription('morphology_dilate_anisotropic'),
    () => expectBrowserReference('morphology_dilate_anisotropic'),
  );
  test(
    referenceDescription('morphology_dilate_horizontal'),
    () => expectBrowserReference('morphology_dilate_horizontal'),
  );
  test(
    referenceDescription('morphology_dilate_vertical'),
    () => expectBrowserReference('morphology_dilate_vertical'),
  );
  test(
    referenceDescription('morphology_dilate_fractional'),
    () => expectBrowserReference('morphology_dilate_fractional'),
  );
  test(
    referenceDescription('morphology_dilate_negative'),
    () => expectBrowserReference('morphology_dilate_negative'),
  );
  test(
    referenceDescription('morphology_dilate_negative_axis'),
    () => expectBrowserReference('morphology_dilate_negative_axis'),
  );
  test(
    referenceDescription('morphology_dilate_large'),
    () => expectBrowserReference('morphology_dilate_large'),
  );
  test(
    referenceDescription('morphology_dilate_linear'),
    () => expectBrowserReference('morphology_dilate_linear'),
  );
  test(
    referenceDescription('morphology_dilate_edge'),
    () => expectBrowserReference('morphology_dilate_edge'),
  );
  test(
    referenceDescription('morphology_dilate_subregion'),
    () => expectBrowserReference('morphology_dilate_subregion'),
  );
  test(
    referenceDescription('morphology_dilate_source_alpha'),
    () => expectBrowserReference('morphology_dilate_source_alpha'),
  );
  test(
    referenceDescription('morphology_dilate_bbox'),
    () => expectBrowserReference('morphology_dilate_bbox'),
  );
  test(
    referenceDescription('morphology_defaults'),
    () => expectBrowserReference('morphology_defaults'),
  );
  test(referenceDescription('morphology_chain'), () => expectBrowserReference('morphology_chain'));
  test(
    referenceDescription('morphology_transform'),
    () => expectBrowserReference('morphology_transform'),
  );

  for (final op in <String>['erode', 'dilate']) {
    for (final radius in <int>[0, 1, 2, 4, 16, 20]) {
      test('exact morphology rectangle $op $radius', () async {
        final ui.Image image = await renderSvg(
          filterSvg('<feMorphology operator="$op" radius="$radius"/>'),
        );
        final Uint8List data = await pixels(image);
        image.dispose();
        final int delta = op == 'dilate' ? radius : -radius;
        for (var y = 0; y < 128; y++) {
          for (var x = 0; x < 128; x++) {
            final bool inside =
                x >= 32 - delta && x < 64 + delta && y >= 32 - delta && y < 64 + delta;
            if (data[(y * 128 + x) * 4 + 3] != (inside ? 255 : 0)) {
              fail('Unexpected $op pixel ($x,$y) radius $radius');
            }
          }
        }
      });
    }
  }
  for (final value in <String>['NaN', 'Infinity', '1e100', 'bad', '1px', '1%', '1 2 3', '']) {
    test('reject malformed radius=$value', () async {
      await expectLater(renderSvg(filterSvg('<feMorphology radius="$value"/>')), throwsA(anything));
    });
  }
  test('unknown morphology operator is diagnosed', () async {
    await expectLater(renderSvg(filterSvg('<feMorphology operator="wrong"/>')), throwsA(anything));
  });
}
