// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final units in <String>['', '4', '2 4', '1.5 2.5']) {
    for (final scale in <double>[1, 2]) {
      for (final preserve in <bool>[false, true]) {
        test('convolution crop preserves grid: $units, $scale, $preserve', () async {
          final values = <Uint8List>[];
          for (final crop in <String>['', 'x="33" y="35" width="37" height="39"']) {
            final ui.Image image = await renderSvg(
              filterSvg(
                '<feConvolveMatrix kernelMatrix="1 2 1 2 4 2 1 2 1" '
                'preserveAlpha="$preserve" $crop '
                '${units.isEmpty ? '' : 'kernelUnitLength="$units"'}/>',
                shape:
                    '<circle cx="51" cy="54" r="20" fill="#b43090" fill-opacity=".8"/> '
                    '<rect x="45" y="31" width="7" height="55" fill="#30c090" fill-opacity=".6"/>',
              ),
              scale: scale,
            );
            values.add((await image.toByteData())!.buffer.asUint8List());
            image.dispose();
          }
          final int width = (128 * scale).round();
          for (int y = (40 * scale).round(); y < 69 * scale; y++) {
            for (int x = (38 * scale).round(); x < 65 * scale; x++) {
              final int p = (y * width + x) * 4;
              for (var c = 0; c < 4; c++) {
                expect(values[1][p + c], closeTo(values[0][p + c], 1), reason: '$x,$y channel $c');
              }
            }
          }
        });
      }
    }
  }
}
