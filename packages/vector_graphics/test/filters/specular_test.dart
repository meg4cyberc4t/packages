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
    referenceDescription('specular_currentcolor'),
    () => expectBrowserReference('specular_currentcolor'),
  );
  test(
    referenceDescription('specular_distant_alpha_ramp'),
    () => expectBrowserReference('specular_distant_alpha_ramp'),
  );
  test(
    referenceDescription('specular_distant_blur'),
    () =>
        expectBrowserReference('specular_distant_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('specular_distant_constant_half'),
    () => expectBrowserReference('specular_distant_constant_half'),
  );
  test(
    referenceDescription('specular_distant_constant_large'),
    () => expectBrowserReference('specular_distant_constant_large'),
  );
  test(
    referenceDescription('specular_distant_constant_zero'),
    () => expectBrowserReference('specular_distant_constant_zero'),
  );
  test(
    referenceDescription('specular_distant_default'),
    () => expectBrowserReference('specular_distant_default'),
  );
  test(
    referenceDescription('specular_distant_kernel_four'),
    () => expectBrowserReference('specular_distant_kernel_four'),
  );
  test(
    referenceDescription('specular_distant_kernel_negative'),
    () => expectBrowserReference('specular_distant_kernel_negative'),
  );
  test(
    referenceDescription('specular_distant_kernel_x'),
    () => expectBrowserReference('specular_distant_kernel_x'),
  );
  test(
    referenceDescription('specular_distant_kernel_y'),
    () => expectBrowserReference('specular_distant_kernel_y'),
  );
  test(
    referenceDescription('specular_distant_kernel_zero'),
    () => expectBrowserReference('specular_distant_kernel_zero'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_0'),
    () => expectBrowserReference('specular_distant_linearRGB_0'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_1'),
    () => expectBrowserReference('specular_distant_linearRGB_1'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_8'),
    () => expectBrowserReference('specular_distant_linearRGB_8'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_neg4'),
    () => expectBrowserReference('specular_distant_linearRGB_neg4'),
  );
  test(
    referenceDescription('specular_distant_merge'),
    () => expectBrowserReference('specular_distant_merge'),
  );
  test(
    referenceDescription('specular_distant_one_pixel'),
    () => expectBrowserReference('specular_distant_one_pixel'),
  );
  test(
    referenceDescription('specular_distant_sRGB_0'),
    () => expectBrowserReference('specular_distant_sRGB_0'),
  );
  test(
    referenceDescription('specular_distant_sRGB_1'),
    () => expectBrowserReference('specular_distant_sRGB_1'),
  );
  test(
    referenceDescription('specular_distant_sRGB_8'),
    () => expectBrowserReference('specular_distant_sRGB_8'),
  );
  test(
    referenceDescription('specular_distant_sRGB_neg4'),
    () => expectBrowserReference('specular_distant_sRGB_neg4'),
  );
  test(
    referenceDescription('specular_distant_subregion'),
    () => expectBrowserReference('specular_distant_subregion'),
  );
  test(
    referenceDescription('specular_distant_transform'),
    () => expectBrowserReference('specular_distant_transform'),
  );
  test(
    referenceDescription('specular_distant_transparent'),
    () => expectBrowserReference('specular_distant_transparent'),
  );
  test(
    referenceDescription('specular_distant_transparent_color'),
    () => expectBrowserReference('specular_distant_transparent_color'),
  );
  test(
    referenceDescription('specular_distant_zero_region'),
    () => expectBrowserReference('specular_distant_zero_region'),
  );
  test(
    referenceDescription('specular_first_light'),
    () => expectBrowserReference('specular_first_light'),
  );
  test(
    referenceDescription('specular_missing_light'),
    () => expectBrowserReference('specular_missing_light'),
  );
  test(
    referenceDescription('specular_point_alpha_ramp'),
    () => expectBrowserReference('specular_point_alpha_ramp'),
  );
  test(
    referenceDescription('specular_point_bbox'),
    () => expectBrowserReference('specular_point_bbox'),
  );
  test(
    referenceDescription('specular_point_blur'),
    () => expectBrowserReference('specular_point_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('specular_point_constant_half'),
    () => expectBrowserReference('specular_point_constant_half'),
  );
  test(
    referenceDescription('specular_point_constant_large'),
    () => expectBrowserReference('specular_point_constant_large'),
  );
  test(
    referenceDescription('specular_point_constant_zero'),
    () => expectBrowserReference('specular_point_constant_zero'),
  );
  test(
    referenceDescription('specular_point_default'),
    () => expectBrowserReference('specular_point_default'),
  );
  test(
    referenceDescription('specular_point_kernel_four'),
    () => expectBrowserReference('specular_point_kernel_four'),
  );
  test(
    referenceDescription('specular_point_kernel_negative'),
    () => expectBrowserReference('specular_point_kernel_negative'),
  );
  test(
    referenceDescription('specular_point_kernel_x'),
    () => expectBrowserReference('specular_point_kernel_x'),
  );
  test(
    referenceDescription('specular_point_kernel_y'),
    () => expectBrowserReference('specular_point_kernel_y'),
  );
  test(
    referenceDescription('specular_point_kernel_zero'),
    () => expectBrowserReference('specular_point_kernel_zero'),
  );
  test(
    referenceDescription('specular_point_linearRGB_0'),
    () => expectBrowserReference('specular_point_linearRGB_0'),
  );
  test(
    referenceDescription('specular_point_linearRGB_1'),
    () => expectBrowserReference('specular_point_linearRGB_1'),
  );
  test(
    referenceDescription('specular_point_linearRGB_8'),
    () => expectBrowserReference('specular_point_linearRGB_8'),
  );
  test(
    referenceDescription('specular_point_linearRGB_neg4'),
    () => expectBrowserReference('specular_point_linearRGB_neg4'),
  );
  test(
    referenceDescription('specular_point_merge'),
    () => expectBrowserReference('specular_point_merge'),
  );
  test(
    referenceDescription('specular_point_one_pixel'),
    () => expectBrowserReference('specular_point_one_pixel'),
  );
  test(
    referenceDescription('specular_point_sRGB_0'),
    () => expectBrowserReference('specular_point_sRGB_0'),
  );
  test(
    referenceDescription('specular_point_sRGB_1'),
    () => expectBrowserReference('specular_point_sRGB_1'),
  );
  test(
    referenceDescription('specular_point_sRGB_8'),
    () => expectBrowserReference('specular_point_sRGB_8'),
  );
  test(
    referenceDescription('specular_point_sRGB_neg4'),
    () => expectBrowserReference('specular_point_sRGB_neg4'),
  );
  test(
    referenceDescription('specular_point_subregion'),
    () => expectBrowserReference('specular_point_subregion'),
  );
  test(
    referenceDescription('specular_point_transform'),
    () => expectBrowserReference('specular_point_transform'),
  );
  test(
    referenceDescription('specular_point_transparent'),
    () => expectBrowserReference('specular_point_transparent'),
  );
  test(
    referenceDescription('specular_point_transparent_color'),
    () => expectBrowserReference('specular_point_transparent_color'),
  );
  test(
    referenceDescription('specular_point_zero_region'),
    () => expectBrowserReference('specular_point_zero_region'),
  );
  test(
    referenceDescription('specular_spot_alpha_ramp'),
    () => expectBrowserReference('specular_spot_alpha_ramp'),
  );
  test(
    referenceDescription('specular_spot_away'),
    () => expectBrowserReference('specular_spot_away'),
  );
  test(
    referenceDescription('specular_spot_bbox'),
    () => expectBrowserReference('specular_spot_bbox'),
  );
  test(
    referenceDescription('specular_spot_blur'),
    () => expectBrowserReference('specular_spot_blur', meanTolerance: 2, maxChannelTolerance: 20),
  );
  test(
    referenceDescription('specular_spot_cone'),
    () => expectBrowserReference('specular_spot_cone'),
  );
  test(
    referenceDescription('specular_spot_constant_half'),
    () => expectBrowserReference('specular_spot_constant_half'),
  );
  test(
    referenceDescription('specular_spot_constant_large'),
    () => expectBrowserReference('specular_spot_constant_large'),
  );
  test(
    referenceDescription('specular_spot_constant_zero'),
    () => expectBrowserReference('specular_spot_constant_zero'),
  );
  test(
    referenceDescription('specular_spot_default'),
    () => expectBrowserReference('specular_spot_default'),
  );
  test(
    referenceDescription('specular_spot_equal'),
    () => expectBrowserReference('specular_spot_equal'),
  );
  test(
    referenceDescription('specular_spot_kernel_four'),
    () => expectBrowserReference('specular_spot_kernel_four'),
  );
  test(
    referenceDescription('specular_spot_kernel_negative'),
    () => expectBrowserReference('specular_spot_kernel_negative'),
  );
  test(
    referenceDescription('specular_spot_kernel_x'),
    () => expectBrowserReference('specular_spot_kernel_x'),
  );
  test(
    referenceDescription('specular_spot_kernel_y'),
    () => expectBrowserReference('specular_spot_kernel_y'),
  );
  test(
    referenceDescription('specular_spot_kernel_zero'),
    () => expectBrowserReference('specular_spot_kernel_zero'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_0'),
    () => expectBrowserReference('specular_spot_linearRGB_0'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_1'),
    () => expectBrowserReference('specular_spot_linearRGB_1'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_8'),
    () => expectBrowserReference('specular_spot_linearRGB_8'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_neg4'),
    () => expectBrowserReference('specular_spot_linearRGB_neg4'),
  );
  test(
    referenceDescription('specular_spot_merge'),
    () => expectBrowserReference('specular_spot_merge'),
  );
  test(
    referenceDescription('specular_spot_one_pixel'),
    () => expectBrowserReference('specular_spot_one_pixel'),
  );
  test(
    referenceDescription('specular_spot_sRGB_0'),
    () => expectBrowserReference('specular_spot_sRGB_0'),
  );
  test(
    referenceDescription('specular_spot_sRGB_1'),
    () => expectBrowserReference('specular_spot_sRGB_1'),
  );
  test(
    referenceDescription('specular_spot_sRGB_8'),
    () => expectBrowserReference('specular_spot_sRGB_8'),
  );
  test(
    referenceDescription('specular_spot_sRGB_neg4'),
    () => expectBrowserReference('specular_spot_sRGB_neg4'),
  );
  test(
    referenceDescription('specular_spot_subregion'),
    () => expectBrowserReference('specular_spot_subregion'),
  );
  test(
    referenceDescription('specular_spot_transform'),
    () => expectBrowserReference('specular_spot_transform'),
  );
  test(
    referenceDescription('specular_spot_transparent'),
    () => expectBrowserReference('specular_spot_transparent'),
  );
  test(
    referenceDescription('specular_spot_transparent_color'),
    () => expectBrowserReference('specular_spot_transparent_color'),
  );
  test(
    referenceDescription('specular_spot_zero_region'),
    () => expectBrowserReference('specular_spot_zero_region'),
  );
  test(referenceDescription('specular_style'), () => expectBrowserReference('specular_style'));
  test(
    referenceDescription('specular_distant_sRGB_exponent_1'),
    () => expectBrowserReference('specular_distant_sRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_distant_sRGB_exponent_4'),
    () => expectBrowserReference('specular_distant_sRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_distant_sRGB_exponent_16'),
    () => expectBrowserReference('specular_distant_sRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_distant_sRGB_exponent_128'),
    () => expectBrowserReference('specular_distant_sRGB_exponent_128'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_exponent_1'),
    () => expectBrowserReference('specular_distant_linearRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_exponent_4'),
    () => expectBrowserReference('specular_distant_linearRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_exponent_16'),
    () => expectBrowserReference('specular_distant_linearRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_distant_linearRGB_exponent_128'),
    () => expectBrowserReference('specular_distant_linearRGB_exponent_128'),
  );
  test(
    referenceDescription('specular_distant_combined'),
    () => expectBrowserReference('specular_distant_combined'),
  );
  test(
    referenceDescription('specular_point_sRGB_exponent_1'),
    () => expectBrowserReference('specular_point_sRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_point_sRGB_exponent_4'),
    () => expectBrowserReference('specular_point_sRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_point_sRGB_exponent_16'),
    () => expectBrowserReference('specular_point_sRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_point_sRGB_exponent_128'),
    () => expectBrowserReference('specular_point_sRGB_exponent_128'),
  );
  test(
    referenceDescription('specular_point_linearRGB_exponent_1'),
    () => expectBrowserReference('specular_point_linearRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_point_linearRGB_exponent_4'),
    () => expectBrowserReference('specular_point_linearRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_point_linearRGB_exponent_16'),
    () => expectBrowserReference('specular_point_linearRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_point_linearRGB_exponent_128'),
    () => expectBrowserReference('specular_point_linearRGB_exponent_128'),
  );
  test(
    // Specular powers amplify small backend blur differences near highlights.
    referenceDescription('specular_point_combined'),
    () => expectBrowserReference(
      'specular_point_combined',
      badPixelFraction: .01,
      maxChannelTolerance: 50,
    ),
  );
  test(
    referenceDescription('specular_spot_sRGB_exponent_1'),
    () => expectBrowserReference('specular_spot_sRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_spot_sRGB_exponent_4'),
    () => expectBrowserReference('specular_spot_sRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_spot_sRGB_exponent_16'),
    () => expectBrowserReference('specular_spot_sRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_spot_sRGB_exponent_128'),
    () => expectBrowserReference('specular_spot_sRGB_exponent_128'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_exponent_1'),
    () => expectBrowserReference('specular_spot_linearRGB_exponent_1'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_exponent_4'),
    () => expectBrowserReference('specular_spot_linearRGB_exponent_4'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_exponent_16'),
    () => expectBrowserReference('specular_spot_linearRGB_exponent_16'),
  );
  test(
    referenceDescription('specular_spot_linearRGB_exponent_128'),
    () => expectBrowserReference('specular_spot_linearRGB_exponent_128'),
  );
  test(
    referenceDescription('specular_spot_combined'),
    () => expectBrowserReference(
      'specular_spot_combined',
      badPixelFraction: .01,
      maxChannelTolerance: 50,
    ),
  );
  test(referenceDescription('specular_black'), () => expectBrowserReference('specular_black'));
  test(referenceDescription('specular_behind'), () => expectBrowserReference('specular_behind'));

  for (final elevation in <double>[-90, 0, 30, 45, 90, 180, 450]) {
    for (final constant in <double>[0, .5, 1, 2]) {
      for (final exponent in <double>[1, 2.5, 16, 128]) {
        test('independent flat Blinn-Phong $elevation $constant $exponent', () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feSpecularLighting surfaceScale="0" specularConstant="$constant" specularExponent="$exponent"><feDistantLight elevation="$elevation"/></feSpecularLighting>',
            ),
          );
          final Uint8List data = await premultipliedPixels(image);
          image.dispose();
          final double halfCosine = math.sqrt(
            ((1 + math.sin(elevation * math.pi / 180)) / 2).clamp(0, 1),
          );
          final double expected = (constant * math.pow(halfCosine, exponent)).clamp(0, 1) * 255;
          for (final point in <int>[0, 64, 128 * 64 + 64, 16383]) {
            expect(data.sublist(point * 4, point * 4 + 4), everyElement(closeTo(expected, 1)));
          }
        });
      }
    }
  }
  for (final attrs in <String>[
    'surfaceScale="NaN"',
    'surfaceScale="1e100"',
    'specularConstant="-1"',
    'specularExponent="0"',
    'specularExponent=".99"',
    'specularExponent="129"',
    'specularExponent="NaN"',
    'specularExponent="1e100"',
    'specularConstant="NaN"',
    'specularConstant="1e100"',
    'kernelUnitLength="1 2 3"',
    'kernelUnitLength=""',
    'kernelUnitLength="1e100"',
    'kernelUnitLength="NaN"',
  ]) {
    test('invalid specular parameter $attrs', () async {
      await expectLater(
        renderSvg(filterSvg('<feSpecularLighting $attrs><feDistantLight/></feSpecularLighting>')),
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
        renderSvg(filterSvg('<feSpecularLighting>$light</feSpecularLighting>')),
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
            '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="3" height="3" color-interpolation-filters="sRGB"><feSpecularLighting surfaceScale="$surface"><feDistantLight azimuth="225" elevation="45"/></feSpecularLighting></filter></defs><g filter="url(#f)">$shape</g></svg>';
        final ui.Image image = await renderSvg(svg);
        final Uint8List data = await premultipliedPixels(image);
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
        final double hz = 1 + math.sqrt(.5);
        final double halfLength = math.sqrt(.5 + hz * hz);
        final double expected = math.max(0, (-.5 * gx - .5 * gy + hz) / length / halfLength) * 255;
        for (var channel = 0; channel < 3; channel++) {
          expect(data[(y * 128 + x) * 4 + channel], closeTo(expected, 2));
        }
        expect(data[(y * 128 + x) * 4 + 3], closeTo(expected, 2));
      });
    }
  }
  for (final size in <(int, int)>[(1, 1), (1, 5), (5, 1), (2, 2)]) {
    test('degenerate flat height field ${size.$1}x${size.$2}', () async {
      final svg =
          '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="${size.$1}" height="${size.$2}" color-interpolation-filters="sRGB"><feSpecularLighting surfaceScale="8"><feDistantLight elevation="90"/></feSpecularLighting></filter></defs><rect width="128" height="128" filter="url(#f)"/></svg>';
      final ui.Image image = await renderSvg(svg);
      final Uint8List data = await premultipliedPixels(image);
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
          '<feSpecularLighting kernelUnitLength="$kernel" surfaceScale="8" $region><fePointLight x="64" y="48" z="64"/></feSpecularLighting>';
      final ui.Image full = await renderSvg(filterSvg(operation('')));
      final ui.Image crop = await renderSvg(
        filterSvg(operation('x="17" y="19" width="65" height="63"')),
      );
      final Uint8List a = await premultipliedPixels(full), b = await premultipliedPixels(crop);
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
    test('explicit kernel keeps specular center stable at scale $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feSpecularLighting kernelUnitLength="2" surfaceScale="0"><feDistantLight elevation="30"/></feSpecularLighting>',
        ),
        scale: scale,
      );
      final Uint8List data = await premultipliedPixels(image);
      final int i = ((64 * scale).floor() * image.width + (64 * scale).floor()) * 4;
      expect(data.sublist(i, i + 3), everyElement(closeTo(math.sqrt(.75) * 255, 1)));
      expect(data[i + 3], closeTo(math.sqrt(.75) * 255, 1));
      image.dispose();
    });
  }
  test('zero-angle cone remains finite and dark', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feSpecularLighting><feSpotLight x="64.5" y="64.5" z="64" pointsAtX="64.5" pointsAtY="64.5" limitingConeAngle="0"/></feSpecularLighting>',
      ),
    );
    final Uint8List data = await premultipliedPixels(image);
    image.dispose();
    for (var i = 0; i < data.length; i += 4) {
      expect(data.sublist(i, i + 4), <int>[0, 0, 0, 0]);
    }
  });
  test('height depends on alpha, independently of source RGB', () async {
    String withColor(String color) => filterSvg(
      '<feSpecularLighting surfaceScale="8"><fePointLight x="64" y="64" z="64"/></feSpecularLighting>',
      shape: '<rect x="32" y="32" width="32" height="32" fill="$color" fill-opacity=".5"/>',
    );
    final ui.Image a = await renderSvg(withColor('red')), b = await renderSvg(withColor('blue'));
    expect(await premultipliedPixels(a), await premultipliedPixels(b));
    a.dispose();
    b.dispose();
  });
  for (final space in <String>['sRGB', 'linearRGB']) {
    for (final color in <String>['#804020', '#2080c0', '#ff0000', 'rgba(64,128,192,.01)']) {
      for (final constant in <double>[0, .25, 1, 4]) {
        test('premultiplied highlight and coverage $space $color $constant', () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feSpecularLighting surfaceScale="0" specularConstant="$constant" lighting-color="$color" color-interpolation-filters="$space"><feDistantLight elevation="90"/></feSpecularLighting>',
            ),
          );
          final Uint8List data = await premultipliedPixels(image);
          image.dispose();
          final List<int> rgb = switch (color) {
            '#804020' => <int>[128, 64, 32],
            '#2080c0' => <int>[32, 128, 192],
            '#ff0000' => <int>[255, 0, 0],
            _ => <int>[64, 128, 192],
          };
          double linear(double v) =>
              v <= .04045 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
          double srgb(double v) => v <= .0031308 ? v * 12.92 : 1.055 * math.pow(v, 1 / 2.4) - .055;
          final List<double> light = rgb
              .map((int b) => space == 'linearRGB' ? linear(b / 255) : b / 255)
              .toList();
          final List<double> premul = light
              .map((double v) => (v * constant).clamp(0.0, 1.0))
              .toList();
          final double alpha = premul.reduce(math.max);
          final List<double> expected = premul
              .map(
                (double v) =>
                    space == 'linearRGB' && alpha > 0 ? srgb(v / alpha) * alpha * 255 : v * 255,
              )
              .toList();
          for (var channel = 0; channel < 3; channel++) {
            expect(data[(64 * 128 + 64) * 4 + channel], closeTo(expected[channel], 2));
          }
          expect(data[(64 * 128 + 64) * 4 + 3], closeTo(alpha * 255, 1));
        });
      }
    }
  }
}

/// Numeric assertions use premultiplied RGBA as defined by the lighting equation.
Future<Uint8List> premultipliedPixels(ui.Image image) async =>
    (await image.toByteData())!.buffer.asUint8List();
