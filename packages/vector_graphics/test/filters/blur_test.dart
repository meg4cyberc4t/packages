// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Approximate Gaussian kernels differ between software Skia and CanvasKit.
  // Affected fixtures allow mean error 2/255, with every channel bounded by
  // 20/255. blur_kernel_test independently checks kernels and edge modes.
  test(referenceDescription('blur_defaults'), () => expectBrowserReference('blur_defaults'));
  test(
    referenceDescription('blur_small'),
    () => expectBrowserReference('blur_small', badPixelFraction: .02),
  );
  test(referenceDescription('blur_isotropic'), () => expectBrowserReference('blur_isotropic'));
  test(referenceDescription('blur_anisotropic'), () => expectBrowserReference('blur_anisotropic'));
  test(referenceDescription('blur_horizontal'), () => expectBrowserReference('blur_horizontal'));
  test(referenceDescription('blur_vertical'), () => expectBrowserReference('blur_vertical'));
  test(referenceDescription('blur_negative'), () => expectBrowserReference('blur_negative'));
  test(
    referenceDescription('blur_negative_axis'),
    () => expectBrowserReference('blur_negative_axis'),
  );
  test(referenceDescription('blur_zero'), () => expectBrowserReference('blur_zero'));
  test(referenceDescription('blur_comma'), () => expectBrowserReference('blur_comma'));
  test(referenceDescription('blur_large'), () => expectBrowserReference('blur_large'));
  test(
    referenceDescription('blur_source_alpha'),
    () => expectBrowserReference('blur_source_alpha'),
  );
  test(referenceDescription('blur_subregion'), () => expectBrowserReference('blur_subregion'));
  test(
    referenceDescription('blur_edge_none'),
    () => expectBrowserReference('blur_edge_none', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(referenceDescription('blur_flood_none'), () => expectBrowserReference('blur_flood_none'));
  test(
    referenceDescription('blur_edge_duplicate'),
    () => expectBrowserReference('blur_edge_duplicate'),
  );
  test(
    referenceDescription('blur_flood_duplicate'),
    () => expectBrowserReference('blur_flood_duplicate'),
  );
  test(
    referenceDescription('blur_edge_wrap'),
    () => expectBrowserReference('blur_edge_wrap', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(referenceDescription('blur_flood_wrap'), () => expectBrowserReference('blur_flood_wrap'));
  test(referenceDescription('blur_linear'), () => expectBrowserReference('blur_linear'));
  test(referenceDescription('blur_bbox'), () => expectBrowserReference('blur_bbox'));
  test(referenceDescription('blur_transform'), () => expectBrowserReference('blur_transform'));
  test(referenceDescription('blur_chain'), () => expectBrowserReference('blur_chain'));
  test(referenceDescription('blur_color_chain'), () => expectBrowserReference('blur_color_chain'));

  for (final value in <String>['NaN', 'Infinity', 'bad', '1px', '1%', '1 2 3', '']) {
    test('reject malformed stdDeviation=$value', () async {
      await expectLater(
        renderSvg(filterSvg('<feGaussianBlur stdDeviation="$value"/>')),
        throwsA(anything),
      );
    });
  }
  for (final value in <String>['0', '-2', '3 -1']) {
    test('disabled blur preserves source $value', () async {
      final ui.Image image = await renderSvg(filterSvg('<feGaussianBlur stdDeviation="$value"/>'));
      final Uint8List data = await pixels(image);
      image.dispose();
      expect(data[(32 * 128 + 32) * 4 + 3], 255);
      expect(data[(31 * 128 + 32) * 4 + 3], 0);
      expect(data[(63 * 128 + 63) * 4 + 3], 255);
      expect(data[(64 * 128 + 63) * 4 + 3], 0);
    });
  }
  test('blur spreads alpha symmetrically and preserves interior color', () async {
    final ui.Image image = await renderSvg(filterSvg('<feGaussianBlur stdDeviation="3"/>'));
    final Uint8List data = await pixels(image);
    image.dispose();
    int alpha(int x, int y) => data[(y * 128 + x) * 4 + 3];
    expect(alpha(30, 48), greaterThan(0));
    expect(alpha(48, 48), greaterThan(250));
    for (var x = 20; x < 76; x++) {
      expect(alpha(x, 48), alpha(95 - x, 48));
    }
    expect(data[(48 * 128 + 40) * 4], 255);
    expect(alpha(10, 10), 0);
  });
  test('one zero axis remains unblurred', () async {
    final ui.Image image = await renderSvg(filterSvg('<feGaussianBlur stdDeviation="4 0"/>'));
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[(31 * 128 + 48) * 4 + 3], 0);
    expect(data[(48 * 128 + 31) * 4 + 3], greaterThan(0));
  });
  test('small Gaussian kernel has the expected edge alpha', () async {
    final ui.Image image = await renderSvg(filterSvg('<feGaussianBlur stdDeviation=".5"/>'));
    final Uint8List data = await pixels(image);
    image.dispose();
    // A normalized sigma=.5 Gaussian places approximately .1065 of its
    // mass one pixel outside an aligned half-plane: .1065 * 255 ~= 27.
    expect(data[(48 * 128 + 31) * 4 + 3], closeTo(27, 2));
    expect(data[(48 * 128 + 32) * 4 + 3], closeTo(228, 2));
  });
  test('invalid edge mode has a diagnostic', () async {
    await expectLater(
      renderSvg(filterSvg('<feGaussianBlur edgeMode="wrong"/>')),
      throwsA(anything),
    );
  });
}
