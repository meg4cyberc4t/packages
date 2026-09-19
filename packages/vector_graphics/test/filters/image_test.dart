// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'image_test_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    referenceDescription('image_png_xMinYMin_meet'),
    () => expectBrowserReference('image_png_xMinYMin_meet'),
  );
  test(
    referenceDescription('image_png_xMinYMin_slice'),
    () => expectBrowserReference('image_png_xMinYMin_slice'),
  );
  test(
    referenceDescription('image_png_xMidYMid_meet'),
    () => expectBrowserReference('image_png_xMidYMid_meet'),
  );
  test(
    referenceDescription('image_png_xMidYMid_slice'),
    () => expectBrowserReference('image_png_xMidYMid_slice'),
  );
  test(
    referenceDescription('image_png_xMaxYMax_meet'),
    () => expectBrowserReference('image_png_xMaxYMax_meet'),
  );
  test(
    referenceDescription('image_png_xMaxYMax_slice'),
    () => expectBrowserReference('image_png_xMaxYMax_slice'),
  );
  test(referenceDescription('image_png_none'), () => expectBrowserReference('image_png_none'));
  test(
    referenceDescription('image_png_default'),
    () => expectBrowserReference('image_png_default'),
  );
  test(
    referenceDescription('image_png_clipped'),
    () => expectBrowserReference('image_png_clipped'),
  );
  test(referenceDescription('image_png_zero'), () => expectBrowserReference('image_png_zero'));
  test(
    referenceDescription('image_png_object_units'),
    () => expectBrowserReference('image_png_object_units'),
  );
  test(
    referenceDescription('image_png_transform'),
    () => expectBrowserReference('image_png_transform'),
  );
  test(referenceDescription('image_png_linear'), () => expectBrowserReference('image_png_linear'));
  test(referenceDescription('image_png_chain'), () => expectBrowserReference('image_png_chain'));
  test(
    referenceDescription('image_svg_xMinYMin_meet'),
    () => expectBrowserReference('image_svg_xMinYMin_meet'),
  );
  test(
    referenceDescription('image_svg_xMinYMin_slice'),
    () => expectBrowserReference('image_svg_xMinYMin_slice'),
  );
  test(
    referenceDescription('image_svg_xMidYMid_meet'),
    () => expectBrowserReference('image_svg_xMidYMid_meet'),
  );
  test(
    referenceDescription('image_svg_xMidYMid_slice'),
    () => expectBrowserReference('image_svg_xMidYMid_slice'),
  );
  test(
    referenceDescription('image_svg_xMaxYMax_meet'),
    () => expectBrowserReference('image_svg_xMaxYMax_meet'),
  );
  test(
    referenceDescription('image_svg_xMaxYMax_slice'),
    () => expectBrowserReference('image_svg_xMaxYMax_slice'),
  );
  test(referenceDescription('image_svg_none'), () => expectBrowserReference('image_svg_none'));
  test(
    referenceDescription('image_svg_default'),
    () => expectBrowserReference('image_svg_default'),
  );
  test(
    referenceDescription('image_svg_clipped'),
    () => expectBrowserReference('image_svg_clipped'),
  );
  test(referenceDescription('image_svg_zero'), () => expectBrowserReference('image_svg_zero'));
  test(
    referenceDescription('image_svg_object_units'),
    () => expectBrowserReference('image_svg_object_units'),
  );
  test(
    referenceDescription('image_svg_transform'),
    () => expectBrowserReference('image_svg_transform'),
  );
  test(referenceDescription('image_svg_linear'), () => expectBrowserReference('image_svg_linear'));
  test(referenceDescription('image_svg_chain'), () => expectBrowserReference('image_svg_chain'));
  test(
    referenceDescription('image_percent_encoded'),
    () => expectBrowserReference('image_percent_encoded'),
  );
  test(referenceDescription('image_missing'), () => expectBrowserReference('image_missing'));
  test(
    referenceDescription('image_broken_raster'),
    () => expectBrowserReference('image_broken_raster'),
  );
  test(referenceDescription('image_broken_svg'), () => expectBrowserReference('image_broken_svg'));
  test(
    referenceDescription('image_missing_fragment'),
    () => expectBrowserReference('image_missing_fragment'),
  );
  test(referenceDescription('image_fragment'), () => expectBrowserReference('image_fragment'));
  test(
    referenceDescription('image_fragment_shift'),
    () => expectBrowserReference('image_fragment_shift'),
  );
  test(
    referenceDescription('image_fragment_size'),
    () => expectBrowserReference('image_fragment_size'),
  );
  test(
    referenceDescription('image_fragment_clip'),
    () => expectBrowserReference('image_fragment_clip'),
  );
  test(
    referenceDescription('image_fragment_group'),
    () => expectBrowserReference('image_fragment_group'),
  );
  test(
    referenceDescription('image_fragment_gradient'),
    () => expectBrowserReference('image_fragment_gradient'),
  );
  test(
    referenceDescription('image_fragment_filter'),
    () => expectBrowserReference('image_fragment_filter'),
  );
  test(referenceDescription('image_self_cycle'), () => expectBrowserReference('image_self_cycle'));
  test(referenceDescription('image_xlink'), () => expectBrowserReference('image_xlink'));
  test(referenceDescription('image_href_first'), () => expectBrowserReference('image_href_first'));
  test(referenceDescription('image_href_last'), () => expectBrowserReference('image_href_last'));

  for (final alignX in <String>['Min', 'Mid', 'Max']) {
    for (final alignY in <String>['Min', 'Mid', 'Max']) {
      for (final sizing in <String>['meet', 'slice']) {
        test('independent aspect ratio $alignX $alignY $sizing', () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feImage href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAQCAYAAAB3AH1ZAAAAJ0lEQVR4nGP4z8DwnxIMRA0U4VEHjDpg1AGjDhh1wKgDRh0w0A4AAGRhfS5rCUtkAAAAAElFTkSuQmCC" x="16" y="16" width="96" height="96" preserveAspectRatio="x${alignX}Y$alignY $sizing"/>',
            ),
          );
          final Uint8List data = await pixels(image);
          image.dispose();
          final double width = sizing == 'meet' ? 96 : 192;
          final double height = sizing == 'meet' ? 48 : 96;
          double fraction(String a) => a == 'Min'
              ? 0
              : a == 'Mid'
              ? .5
              : 1;
          final double left = 16 + (96 - width) * fraction(alignX);
          final double top = 16 + (96 - height) * fraction(alignY);
          for (var y = 0; y < 128; y += 4) {
            for (var x = 0; x < 128; x += 4) {
              if ((x - left - width / 2).abs() < 4 ||
                  (y - top).abs() < 4 ||
                  (y - top - height).abs() < 4) {
                continue;
              }
              final bool inside =
                  x >= 16 &&
                  x < 112 &&
                  y >= 16 &&
                  y < 112 &&
                  x >= left &&
                  x < left + width &&
                  y >= top &&
                  y < top + height;
              final a = !inside
                  ? 0
                  : x < left + width / 2
                  ? 255
                  : 128;
              expect(data[(y * 128 + x) * 4 + 3], a, reason: '$x,$y');
            }
          }
        });
      }
    }
  }
  for (final value in <String>[
    'bad',
    'xMidYMid wrong',
    'xBadYMid',
    'defer',
    'xMidYMid meet extra',
  ]) {
    test('invalid image aspect ratio $value', () async {
      await expectLater(
        renderSvg(
          filterSvg(
            '<feImage href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAQCAYAAAB3AH1ZAAAAJ0lEQVR4nGP4z8DwnxIMRA0U4VEHjDpg1AGjDhh1wKgDRh0w0A4AAGRhfS5rCUtkAAAAAElFTkSuQmCC" preserveAspectRatio="$value"/>',
          ),
        ),
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
  test(referenceDescription('image_x_negative'), () => expectBrowserReference('image_x_negative'));
  test(referenceDescription('image_x_percent'), () => expectBrowserReference('image_x_percent'));
  test(referenceDescription('image_x_decimal'), () => expectBrowserReference('image_x_decimal'));
  test(referenceDescription('image_y_negative'), () => expectBrowserReference('image_y_negative'));
  test(referenceDescription('image_y_percent'), () => expectBrowserReference('image_y_percent'));
  test(referenceDescription('image_y_decimal'), () => expectBrowserReference('image_y_decimal'));

  test(referenceDescription('image_width_0'), () => expectBrowserReference('image_width_0'));
  test(referenceDescription('image_width_1'), () => expectBrowserReference('image_width_1'));
  test(
    referenceDescription('image_width_25pct'),
    () => expectBrowserReference('image_width_25pct'),
  );

  test(referenceDescription('image_height_0'), () => expectBrowserReference('image_height_0'));
  test(referenceDescription('image_height_1'), () => expectBrowserReference('image_height_1'));
  test(
    referenceDescription('image_height_25pct'),
    () => expectBrowserReference('image_height_25pct'),
  );
  test(referenceDescription('image_result'), () => expectBrowserReference('image_result'));
  test(referenceDescription('image_defer'), () => expectBrowserReference('image_defer'));
  test(referenceDescription('image_ignore_in'), () => expectBrowserReference('image_ignore_in'));
  test(
    referenceDescription('image_fragment_forward'),
    () => expectBrowserReference('image_fragment_forward'),
  );
  test(
    referenceDescription('image_fragment_bbox'),
    () => expectBrowserReference('image_fragment_bbox'),
  );
  test(
    referenceDescription('image_fragment_inheritance'),
    () => expectBrowserReference('image_fragment_inheritance'),
  );
  test(
    referenceDescription('image_fragment_viewbox'),
    () => expectBrowserReference('image_fragment_viewbox'),
  );
  test(
    referenceDescription('image_fragment_use'),
    () => expectBrowserReference('image_fragment_use'),
  );

  for (final kind in <String>['png', 'svg']) {
    final String encoded = kind == 'png' ? filterImagePng : filterImageSvg;
    final mime = kind == 'png' ? 'image/png' : 'image/svg+xml';
    for (final href in <String>[
      'photo',
      'photo.ext',
      '../assets/photo',
      'https://example.invalid/photo',
    ]) {
      test('preloaded $kind $href equals embedded resource', () async {
        final ui.Image external = await renderSvg(
          filterSvg('<feImage href="$href"/>'),
          imageSources: <String, Uint8List>{href: base64Decode(encoded)},
        );
        final ui.Image embedded = await renderSvg(
          filterSvg('<feImage href="data:$mime;base64,$encoded"/>'),
        );
        expect(await pixels(external), await pixels(embedded));
        external.dispose();
        embedded.dispose();
      });
    }
    for (final whitespace in <String>[' ', '%20', '&#10;', '&#9;']) {
      test('$kind base64 whitespace $whitespace', () async {
        final String spaced = encoded.substring(0, 20) + whitespace + encoded.substring(20);
        final ui.Image actual = await renderSvg(
          filterSvg('<feImage href="data:$mime;base64,$spaced"/>'),
        );
        final ui.Image expected = await renderSvg(
          filterSvg('<feImage href="data:$mime;base64,$encoded"/>'),
        );
        expect(await pixels(actual), await pixels(expected));
        actual.dispose();
        expected.dispose();
      });
    }
  }
  for (final href in <String>[
    '',
    '#unknown',
    'unprovided.png',
    'data:image/png;base64,AAAA',
    'data:image/svg+xml,%3Csvg',
    'data:image/png;base64,!bad',
    'data:text/xml,%3Cother/%3E',
  ]) {
    test('invalid resource is transparent: $href', () async {
      final ui.Image image = await renderSvg(filterSvg('<feImage href="$href"/>'));
      expect((await pixels(image)).every((int c) => c == 0), isTrue);
      image.dispose();
    });
  }
  for (final key in <String>['external.svg', 'external.svg#piece']) {
    test('external fragment lookup with map key $key', () async {
      const resource =
          '<svg width="128" height="128"><rect id="piece" x="24" y="32" width="32" height="16" fill="blue"/></svg>';
      final ui.Image image = await renderSvg(
        filterSvg('<feImage href="external.svg#piece"/>'),
        imageSources: <String, Uint8List>{key: Uint8List.fromList(utf8.encode(resource))},
      );
      final Uint8List data = await pixels(image);
      image.dispose();
      expect(data.sublist((40 * 128 + 32) * 4, (40 * 128 + 32) * 4 + 4), <int>[0, 0, 255, 255]);
      expect(data[(16 * 128 + 16) * 4 + 3], 0);
    });
  }
  for (final scale in <double>[.5, 1, 2, 4]) {
    test('native vector detail survives image enlargement $scale', () async {
      const resource =
          '<svg width="128" height="128"><rect x="32" y="32" width=".5" height="32" fill="red"/></svg>';
      final ui.Image image = await renderSvg(
        filterSvg('<feImage href="vector.svg"/>'),
        scale: scale,
        imageSources: <String, Uint8List>{'vector.svg': Uint8List.fromList(utf8.encode(resource))},
      );
      final Uint8List data = await pixels(image);
      final int w = image.width;
      // Subpixel coverage differs between GPU backends. Compare the same
      // vector geometry drawn directly, so an intrinsic-size raster fallback
      // still fails when the image is enlarged.
      final ui.Image direct = await renderSvg(resource, scale: scale);
      expect(data, await pixels(direct));
      direct.dispose();
      expect(data[((40 * scale).floor() * w + (32 * scale).floor()) * 4 + 3], greaterThan(0));
      expect(data[((40 * scale).floor() * w + (32 * scale).floor() + 3) * 4 + 3], 0);
      image.dispose();
    });
  }
  for (final axis in <String>['width', 'height']) {
    test('negative image $axis is diagnosed', () async {
      await expectLater(
        renderSvg(filterSvg('<feImage $axis="-1"/>')),
        throwsA(
          isA<Object>().having(
            (Object e) => e.toString(),
            'diagnostic',
            contains('dimensions must not be negative'),
          ),
        ),
      );
    });
  }
}
