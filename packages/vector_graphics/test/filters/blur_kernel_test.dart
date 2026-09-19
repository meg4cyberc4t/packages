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
  for (final sigma in <double>[2, 4, 5, 8]) {
    for (final edge in <String>['none', 'duplicate', 'wrap']) {
      test('Gaussian scalar kernel and $edge boundaries at sigma=$sigma', () async {
        final ui.Image image = await renderSvg(
          filterSvg(
            '<feGaussianBlur stdDeviation="$sigma 0" edgeMode="$edge"/>',
            shape:
                '<rect width="32" height="128" fill="white"/> '
                '<rect x="64" width="64" height="128" fill="white" fill-opacity=".5"/>',
          ),
        );
        final Uint8List data = await pixels(image);
        image.dispose();
        final int radius = (3 * sigma).ceil();
        final weights = <double>[
          for (int k = -radius; k <= radius; k++) math.exp(-k * k / (2 * sigma * sigma)),
        ];
        final double total = weights.reduce((double a, double b) => a + b);
        double alpha(int x) {
          if (edge == 'wrap') {
            x %= 128;
          } else if (edge == 'duplicate') {
            x = x.clamp(0, 127);
          } else if (x < 0 || x >= 128) {
            return 0;
          }
          return x < 32
              ? 255
              : x < 64
              ? 0
              : 128;
        }

        for (var x = 0; x < 128; x++) {
          var expected = 0.0;
          for (int k = -radius; k <= radius; k++) {
            expected += alpha(x + k) * weights[k + radius] / total;
          }
          // SVG permits an approximate kernel for sigma >= 2. This scalar
          // Gaussian oracle limits pointwise error to about 3% of full alpha.
          // https://www.w3.org/TR/filter-effects-1/#feGaussianBlurElement
          expect(data[(64 * 128 + x) * 4 + 3], closeTo(expected, 8), reason: 'x=$x');
        }
      });
    }
  }
}
