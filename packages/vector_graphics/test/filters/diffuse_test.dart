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
  // Approximate Gaussian kernels differ between software Skia and CanvasKit.
  // Affected fixtures allow mean error 2/255, with every channel bounded by
  // 20/255. blur_kernel_test independently checks kernels and edge modes.
  test(
    referenceDescription('diffuse_distant_sRGB_0'),
    () => expectBrowserReference('diffuse_distant_sRGB_0'),
  );
  test(
    referenceDescription('diffuse_distant_sRGB_1'),
    () => expectBrowserReference('diffuse_distant_sRGB_1'),
  );
  test(
    referenceDescription('diffuse_distant_sRGB_8'),
    () => expectBrowserReference('diffuse_distant_sRGB_8'),
  );
  test(
    referenceDescription('diffuse_distant_sRGB_neg4'),
    () => expectBrowserReference('diffuse_distant_sRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_distant_linearRGB_0'),
    () => expectBrowserReference('diffuse_distant_linearRGB_0'),
  );
  test(
    referenceDescription('diffuse_distant_linearRGB_1'),
    () => expectBrowserReference('diffuse_distant_linearRGB_1'),
  );
  test(
    referenceDescription('diffuse_distant_linearRGB_8'),
    () => expectBrowserReference('diffuse_distant_linearRGB_8'),
  );
  test(
    referenceDescription('diffuse_distant_linearRGB_neg4'),
    () => expectBrowserReference('diffuse_distant_linearRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_distant_default'),
    () => expectBrowserReference('diffuse_distant_default'),
  );
  test(
    referenceDescription('diffuse_distant_constant_zero'),
    () => expectBrowserReference('diffuse_distant_constant_zero'),
  );
  test(
    referenceDescription('diffuse_distant_constant_half'),
    () => expectBrowserReference('diffuse_distant_constant_half'),
  );
  test(
    referenceDescription('diffuse_distant_constant_large'),
    () => expectBrowserReference('diffuse_distant_constant_large'),
  );
  test(
    referenceDescription('diffuse_distant_transparent_color'),
    () => expectBrowserReference('diffuse_distant_transparent_color'),
  );
  test(
    referenceDescription('diffuse_distant_subregion'),
    () => expectBrowserReference('diffuse_distant_subregion'),
  );
  test(
    referenceDescription('diffuse_distant_zero_region'),
    () => expectBrowserReference('diffuse_distant_zero_region'),
  );
  test(
    referenceDescription('diffuse_distant_one_pixel'),
    () => expectBrowserReference('diffuse_distant_one_pixel'),
  );
  test(
    referenceDescription('diffuse_distant_kernel_x'),
    () => expectBrowserReference('diffuse_distant_kernel_x'),
  );
  test(
    referenceDescription('diffuse_distant_kernel_y'),
    () => expectBrowserReference('diffuse_distant_kernel_y'),
  );
  test(
    referenceDescription('diffuse_distant_kernel_four'),
    () => expectBrowserReference('diffuse_distant_kernel_four'),
  );
  test(
    referenceDescription('diffuse_distant_kernel_zero'),
    () => expectBrowserReference('diffuse_distant_kernel_zero'),
  );
  test(
    referenceDescription('diffuse_distant_kernel_negative'),
    () => expectBrowserReference('diffuse_distant_kernel_negative'),
  );
  test(
    referenceDescription('diffuse_distant_alpha_ramp'),
    () => expectBrowserReference('diffuse_distant_alpha_ramp'),
  );
  test(
    referenceDescription('diffuse_distant_transparent'),
    () => expectBrowserReference('diffuse_distant_transparent'),
  );
  test(
    referenceDescription('diffuse_distant_transform'),
    () => expectBrowserReference('diffuse_distant_transform'),
  );
  test(
    referenceDescription('diffuse_distant_blur'),
    () => expectBrowserReference('diffuse_distant_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('diffuse_distant_merge'),
    () => expectBrowserReference('diffuse_distant_merge'),
  );
  test(
    referenceDescription('diffuse_point_sRGB_0'),
    () => expectBrowserReference('diffuse_point_sRGB_0'),
  );
  test(
    referenceDescription('diffuse_point_sRGB_1'),
    () => expectBrowserReference('diffuse_point_sRGB_1'),
  );
  test(
    referenceDescription('diffuse_point_sRGB_8'),
    () => expectBrowserReference('diffuse_point_sRGB_8'),
  );
  test(
    referenceDescription('diffuse_point_sRGB_neg4'),
    () => expectBrowserReference('diffuse_point_sRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_point_linearRGB_0'),
    () => expectBrowserReference('diffuse_point_linearRGB_0'),
  );
  test(
    referenceDescription('diffuse_point_linearRGB_1'),
    () => expectBrowserReference('diffuse_point_linearRGB_1'),
  );
  test(
    referenceDescription('diffuse_point_linearRGB_8'),
    () => expectBrowserReference('diffuse_point_linearRGB_8'),
  );
  test(
    referenceDescription('diffuse_point_linearRGB_neg4'),
    () => expectBrowserReference('diffuse_point_linearRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_point_default'),
    () => expectBrowserReference('diffuse_point_default'),
  );
  test(
    referenceDescription('diffuse_point_constant_zero'),
    () => expectBrowserReference('diffuse_point_constant_zero'),
  );
  test(
    referenceDescription('diffuse_point_constant_half'),
    () => expectBrowserReference('diffuse_point_constant_half'),
  );
  test(
    referenceDescription('diffuse_point_constant_large'),
    () => expectBrowserReference('diffuse_point_constant_large'),
  );
  test(
    referenceDescription('diffuse_point_transparent_color'),
    () => expectBrowserReference('diffuse_point_transparent_color'),
  );
  test(
    referenceDescription('diffuse_point_subregion'),
    () => expectBrowserReference('diffuse_point_subregion'),
  );
  test(
    referenceDescription('diffuse_point_zero_region'),
    () => expectBrowserReference('diffuse_point_zero_region'),
  );
  test(
    referenceDescription('diffuse_point_one_pixel'),
    () => expectBrowserReference('diffuse_point_one_pixel'),
  );
  test(
    referenceDescription('diffuse_point_kernel_x'),
    () => expectBrowserReference('diffuse_point_kernel_x'),
  );
  test(
    referenceDescription('diffuse_point_kernel_y'),
    () => expectBrowserReference('diffuse_point_kernel_y'),
  );
  test(
    referenceDescription('diffuse_point_kernel_four'),
    () => expectBrowserReference('diffuse_point_kernel_four'),
  );
  test(
    referenceDescription('diffuse_point_kernel_zero'),
    () => expectBrowserReference('diffuse_point_kernel_zero'),
  );
  test(
    referenceDescription('diffuse_point_kernel_negative'),
    () => expectBrowserReference('diffuse_point_kernel_negative'),
  );
  test(
    referenceDescription('diffuse_point_alpha_ramp'),
    () => expectBrowserReference('diffuse_point_alpha_ramp'),
  );
  test(
    referenceDescription('diffuse_point_transparent'),
    () => expectBrowserReference('diffuse_point_transparent'),
  );
  test(
    referenceDescription('diffuse_point_transform'),
    () => expectBrowserReference('diffuse_point_transform'),
  );
  test(
    referenceDescription('diffuse_point_blur'),
    () => expectBrowserReference('diffuse_point_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('diffuse_point_merge'),
    () => expectBrowserReference('diffuse_point_merge'),
  );
  test(
    referenceDescription('diffuse_spot_sRGB_0'),
    () => expectBrowserReference('diffuse_spot_sRGB_0'),
  );
  test(
    referenceDescription('diffuse_spot_sRGB_1'),
    () => expectBrowserReference('diffuse_spot_sRGB_1'),
  );
  test(
    referenceDescription('diffuse_spot_sRGB_8'),
    () => expectBrowserReference('diffuse_spot_sRGB_8'),
  );
  test(
    referenceDescription('diffuse_spot_sRGB_neg4'),
    () => expectBrowserReference('diffuse_spot_sRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_spot_linearRGB_0'),
    () => expectBrowserReference('diffuse_spot_linearRGB_0'),
  );
  test(
    referenceDescription('diffuse_spot_linearRGB_1'),
    () => expectBrowserReference('diffuse_spot_linearRGB_1'),
  );
  test(
    referenceDescription('diffuse_spot_linearRGB_8'),
    () => expectBrowserReference('diffuse_spot_linearRGB_8'),
  );
  test(
    referenceDescription('diffuse_spot_linearRGB_neg4'),
    () => expectBrowserReference('diffuse_spot_linearRGB_neg4'),
  );
  test(
    referenceDescription('diffuse_spot_default'),
    () => expectBrowserReference('diffuse_spot_default'),
  );
  test(
    referenceDescription('diffuse_spot_constant_zero'),
    () => expectBrowserReference('diffuse_spot_constant_zero'),
  );
  test(
    referenceDescription('diffuse_spot_constant_half'),
    () => expectBrowserReference('diffuse_spot_constant_half'),
  );
  test(
    referenceDescription('diffuse_spot_constant_large'),
    () => expectBrowserReference('diffuse_spot_constant_large'),
  );
  test(
    referenceDescription('diffuse_spot_transparent_color'),
    () => expectBrowserReference('diffuse_spot_transparent_color'),
  );
  test(
    referenceDescription('diffuse_spot_subregion'),
    () => expectBrowserReference('diffuse_spot_subregion'),
  );
  test(
    referenceDescription('diffuse_spot_zero_region'),
    () => expectBrowserReference('diffuse_spot_zero_region'),
  );
  test(
    referenceDescription('diffuse_spot_one_pixel'),
    () => expectBrowserReference('diffuse_spot_one_pixel'),
  );
  test(
    referenceDescription('diffuse_spot_kernel_x'),
    () => expectBrowserReference('diffuse_spot_kernel_x'),
  );
  test(
    referenceDescription('diffuse_spot_kernel_y'),
    () => expectBrowserReference('diffuse_spot_kernel_y'),
  );
  test(
    referenceDescription('diffuse_spot_kernel_four'),
    () => expectBrowserReference('diffuse_spot_kernel_four'),
  );
  test(
    referenceDescription('diffuse_spot_kernel_zero'),
    () => expectBrowserReference('diffuse_spot_kernel_zero'),
  );
  test(
    referenceDescription('diffuse_spot_kernel_negative'),
    () => expectBrowserReference('diffuse_spot_kernel_negative'),
  );
  test(
    referenceDescription('diffuse_spot_alpha_ramp'),
    () => expectBrowserReference('diffuse_spot_alpha_ramp'),
  );
  test(
    referenceDescription('diffuse_spot_transparent'),
    () => expectBrowserReference('diffuse_spot_transparent'),
  );
  test(
    referenceDescription('diffuse_spot_transform'),
    () => expectBrowserReference('diffuse_spot_transform'),
  );
  test(
    referenceDescription('diffuse_spot_blur'),
    () => expectBrowserReference('diffuse_spot_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('diffuse_spot_merge'),
    () => expectBrowserReference('diffuse_spot_merge'),
  );
  test(
    referenceDescription('diffuse_missing_light'),
    () => expectBrowserReference('diffuse_missing_light'),
  );
  test(
    referenceDescription('diffuse_first_light'),
    () => expectBrowserReference('diffuse_first_light'),
  );
  test(
    referenceDescription('diffuse_spot_cone'),
    () => expectBrowserReference('diffuse_spot_cone'),
  );
  test(
    referenceDescription('diffuse_spot_away'),
    () => expectBrowserReference('diffuse_spot_away'),
  );
  test(
    referenceDescription('diffuse_spot_equal'),
    () => expectBrowserReference('diffuse_spot_equal'),
  );
  test(
    referenceDescription('diffuse_point_bbox'),
    () => expectBrowserReference('diffuse_point_bbox'),
  );
  test(
    referenceDescription('diffuse_spot_bbox'),
    () => expectBrowserReference('diffuse_spot_bbox'),
  );
  test(
    referenceDescription('diffuse_currentcolor'),
    () => expectBrowserReference('diffuse_currentcolor'),
  );
  test(referenceDescription('diffuse_style'), () => expectBrowserReference('diffuse_style'));

  for (final elevation in <double>[-90, 0, 30, 45, 90, 180, 450]) {
    for (final constant in <double>[0, .5, 1, 2]) {
      test('flat plane independent Lambert law $elevation $constant', () async {
        final ui.Image image = await renderSvg(
          filterSvg(
            '<feDiffuseLighting surfaceScale="0" diffuseConstant="$constant"><feDistantLight elevation="$elevation"/></feDiffuseLighting>',
          ),
        );
        final Uint8List data = await pixels(image);
        image.dispose();
        final double expected =
            (math.max(0, math.sin(elevation * math.pi / 180)) * constant).clamp(0, 1) * 255;
        for (final point in <int>[0, 64, 128 * 64 + 64, 16383]) {
          for (var c = 0; c < 3; c++) {
            expect(data[point * 4 + c], closeTo(expected, 1));
          }
          expect(data[point * 4 + 3], 255);
        }
      });
    }
  }
  for (final attrs in <String>[
    'surfaceScale="NaN"',
    'surfaceScale="1e100"',
    'diffuseConstant="-1"',
    'diffuseConstant="NaN"',
    'diffuseConstant="1e100"',
    'kernelUnitLength="1 2 3"',
    'kernelUnitLength=""',
    'kernelUnitLength="1e100"',
    'kernelUnitLength="NaN"',
  ]) {
    test('invalid diffuse parameter $attrs', () async {
      await expectLater(
        renderSvg(filterSvg('<feDiffuseLighting $attrs><feDistantLight/></feDiffuseLighting>')),
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
  for (final light in <String>[
    '<feDistantLight azimuth="NaN"/>',
    '<feDistantLight elevation="Infinity"/>',
    '<fePointLight x="1px"/>',
    '<fePointLight y="50%"/>',
    '<fePointLight z="NaN"/>',
    '<feSpotLight pointsAtX="NaN"/>',
    '<feSpotLight pointsAtY="1e100"/>',
    '<feSpotLight pointsAtZ="NaN"/>',
    '<feSpotLight specularExponent="-1"/>',
    '<feSpotLight limitingConeAngle="NaN"/>',
  ]) {
    test('invalid light $light', () async {
      await expectLater(
        renderSvg(filterSvg('<feDiffuseLighting>$light</feDiffuseLighting>')),
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

  // Published SVG 1.1 corner, edge, and interior kernels. Kept as explicit
  // matrices here, independently of the shader's separable edge formulation.
  const kernelsX = <List<double>>[
    <double>[0, 0, 0, 0, -2, 2, 0, -1, 1],
    <double>[0, 0, 0, -2, 0, 2, -1, 0, 1],
    <double>[0, 0, 0, -2, 2, 0, -1, 1, 0],
    <double>[0, -1, 1, 0, -2, 2, 0, -1, 1],
    <double>[-1, 0, 1, -2, 0, 2, -1, 0, 1],
    <double>[-1, 1, 0, -2, 2, 0, -1, 1, 0],
    <double>[0, -1, 1, 0, -2, 2, 0, 0, 0],
    <double>[-1, 0, 1, -2, 0, 2, 0, 0, 0],
    <double>[-1, 1, 0, -2, 2, 0, 0, 0, 0],
  ];
  const factorsX = <double>[2 / 3, 1 / 3, 2 / 3, 1 / 2, 1 / 4, 1 / 2, 2 / 3, 1 / 3, 2 / 3];
  const height = <int>[0, 64, 128, 32, 128, 192, 64, 192, 255];
  for (final surface in <double>[.25, 1, 8, -4]) {
    for (var index = 0; index < 9; index++) {
      test('independent normal at edge/corner/interior $index surface $surface', () async {
        final String shape = List<String>.generate(
          9,
          (int i) =>
              '<rect x="${i % 3}" y="${i ~/ 3}" width="1" height="1" fill="red" fill-opacity="${height[i] / 255}"/>',
        ).join();
        final svg =
            '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="3" height="3" color-interpolation-filters="sRGB"><feDiffuseLighting surfaceScale="$surface"><feDistantLight azimuth="225" elevation="45"/></feDiffuseLighting></filter></defs><g filter="url(#f)">$shape</g></svg>';
        final ui.Image image = await renderSvg(svg);
        final Uint8List data = await pixels(image);
        image.dispose();
        final int x = index % 3, y = index ~/ 3;
        double gx = 0, gy = 0;
        for (var ky = 0; ky < 3; ky++) {
          for (var kx = 0; kx < 3; kx++) {
            final int sx = x + kx - 1, sy = y + ky - 1;
            if (sx < 0 || sx >= 3 || sy < 0 || sy >= 3) {
              continue;
            }
            final double alpha = height[sy * 3 + sx] / 255;
            gx += kernelsX[index][ky * 3 + kx] * alpha;
            gy += kernelsX[x * 3 + y][kx * 3 + ky] * alpha;
          }
        }
        gx *= -surface * factorsX[index];
        gy *= -surface * factorsX[x * 3 + y];
        final double length = math.sqrt(gx * gx + gy * gy + 1);
        final double expected = math.max(0, (-.5 * gx - .5 * gy + math.sqrt(.5)) / length) * 255;
        for (var channel = 0; channel < 3; channel++) {
          expect(data[(y * 128 + x) * 4 + channel], closeTo(expected, 2));
        }
        expect(data[(y * 128 + x) * 4 + 3], 255);
      });
    }
  }
  for (final size in <(int, int)>[(1, 1), (1, 5), (5, 1), (2, 2)]) {
    test('degenerate flat height field ${size.$1}x${size.$2}', () async {
      final svg =
          '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="${size.$1}" height="${size.$2}" color-interpolation-filters="sRGB"><feDiffuseLighting surfaceScale="8"><feDistantLight elevation="90"/></feDiffuseLighting></filter></defs><rect width="128" height="128" filter="url(#f)"/></svg>';
      final ui.Image image = await renderSvg(svg);
      final Uint8List data = await pixels(image);
      image.dispose();
      for (var y = 0; y < size.$2; y++) {
        for (var x = 0; x < size.$1; x++) {
          expect(data.sublist((y * 128 + x) * 4, (y * 128 + x) * 4 + 4), <int>[255, 255, 255, 255]);
        }
      }
    });
  }

  for (final kernel in <String>['2 4', '4 2', '1.5 2.5']) {
    test('clipping keeps the temporary lighting grid aligned: $kernel', () async {
      String operation(String region) =>
          '<feDiffuseLighting kernelUnitLength="$kernel" surfaceScale="8" $region><fePointLight x="64" y="48" z="64"/></feDiffuseLighting>';
      final ui.Image full = await renderSvg(filterSvg(operation('')));
      final ui.Image crop = await renderSvg(
        filterSvg(operation('x="17" y="19" width="65" height="63"')),
      );
      final Uint8List a = await pixels(full), b = await pixels(crop);
      full.dispose();
      crop.dispose();
      for (var y = 24; y < 78; y++) {
        for (var x = 22; x < 78; x++) {
          expect(b[(y * 128 + x) * 4], closeTo(a[(y * 128 + x) * 4], 2), reason: '$x,$y');
        }
      }
    });
  }
  for (final scale in <double>[.5, 2, 4]) {
    test('explicit kernel keeps diffuse center stable at scale $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feDiffuseLighting kernelUnitLength="2" surfaceScale="0"><feDistantLight elevation="30"/></feDiffuseLighting>',
        ),
        scale: scale,
      );
      final Uint8List data = await pixels(image);
      final int i = ((64 * scale).floor() * image.width + (64 * scale).floor()) * 4;
      expect(data.sublist(i, i + 3), everyElement(closeTo(127.5, 1)));
      expect(data[i + 3], 255);
      image.dispose();
    });
  }
  test('zero-angle cone remains finite and dark', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feDiffuseLighting><feSpotLight x="64.5" y="64.5" z="64" pointsAtX="64.5" pointsAtY="64.5" limitingConeAngle="0"/></feDiffuseLighting>',
      ),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    for (var i = 0; i < data.length; i += 4) {
      expect(data.sublist(i, i + 4), <int>[0, 0, 0, 255]);
    }
  });
  test('height depends on alpha, independently of source RGB', () async {
    String withColor(String color) => filterSvg(
      '<feDiffuseLighting surfaceScale="8"><fePointLight x="64" y="64" z="64"/></feDiffuseLighting>',
      shape: '<rect x="32" y="32" width="32" height="32" fill="$color" fill-opacity=".5"/>',
    );
    final ui.Image a = await renderSvg(withColor('red')), b = await renderSvg(withColor('blue'));
    expect(await pixels(a), await pixels(b));
    a.dispose();
    b.dispose();
  });
}
