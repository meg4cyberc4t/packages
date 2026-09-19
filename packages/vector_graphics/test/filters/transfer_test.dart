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
  for (final scale in <double>[.5, 1, 2, 3]) {
    test('lookup table precision is independent of raster scale $scale', () async {
      final ui.Image image = await renderSvg(
        filterSvg(
          '<feFlood flood-color="rgb(128,128,128)"/> '
          '<feComponentTransfer><feFuncR type="table" tableValues="-1 2"/></feComponentTransfer>',
        ),
        scale: scale,
      );
      final Uint8List data = await pixels(image);
      final int p = ((40 * scale).round() * image.width + (40 * scale).round()) * 4;
      image.dispose();
      expect(data[p], closeTo(129, 1));
      expect(data[p + 3], 255);
    });
  }
  test(
    referenceDescription('transfer_identity_sRGB'),
    () => expectBrowserReference('transfer_identity_sRGB'),
  );
  test(
    referenceDescription('transfer_identity_linearRGB'),
    () => expectBrowserReference('transfer_identity_linearRGB'),
  );
  test(
    referenceDescription('transfer_table_sRGB'),
    () => expectBrowserReference('transfer_table_sRGB'),
  );
  test(
    referenceDescription('transfer_table_linearRGB'),
    () => expectBrowserReference('transfer_table_linearRGB'),
  );
  test(
    referenceDescription('transfer_discrete_sRGB'),
    () => expectBrowserReference('transfer_discrete_sRGB'),
  );
  test(
    referenceDescription('transfer_discrete_linearRGB'),
    () => expectBrowserReference('transfer_discrete_linearRGB'),
  );
  test(
    referenceDescription('transfer_linear_sRGB'),
    () => expectBrowserReference('transfer_linear_sRGB'),
  );
  test(
    referenceDescription('transfer_linear_linearRGB'),
    () => expectBrowserReference('transfer_linear_linearRGB'),
  );
  test(
    referenceDescription('transfer_gamma_sRGB'),
    () => expectBrowserReference('transfer_gamma_sRGB'),
  );
  test(
    referenceDescription('transfer_gamma_linearRGB'),
    () => expectBrowserReference('transfer_gamma_linearRGB'),
  );
  test(
    referenceDescription('transfer_table_empty_sRGB'),
    () => expectBrowserReference('transfer_table_empty_sRGB'),
  );
  test(
    referenceDescription('transfer_table_empty_linearRGB'),
    () => expectBrowserReference('transfer_table_empty_linearRGB'),
  );
  test(
    referenceDescription('transfer_table_single_sRGB'),
    () => expectBrowserReference('transfer_table_single_sRGB'),
  );
  test(
    referenceDescription('transfer_table_single_linearRGB'),
    () => expectBrowserReference('transfer_table_single_linearRGB'),
  );
  test(
    referenceDescription('transfer_discrete_single_sRGB'),
    () => expectBrowserReference('transfer_discrete_single_sRGB'),
  );
  test(
    referenceDescription('transfer_discrete_single_linearRGB'),
    () => expectBrowserReference('transfer_discrete_single_linearRGB'),
  );
  test(
    referenceDescription('transfer_table_outside_sRGB'),
    () => expectBrowserReference('transfer_table_outside_sRGB'),
  );
  test(
    referenceDescription('transfer_table_outside_linearRGB'),
    () => expectBrowserReference('transfer_table_outside_linearRGB'),
  );
  test(
    referenceDescription('transfer_alpha_table_sRGB'),
    () => expectBrowserReference('transfer_alpha_table_sRGB'),
  );
  test(
    referenceDescription('transfer_alpha_table_linearRGB'),
    () => expectBrowserReference('transfer_alpha_table_linearRGB'),
  );
  test(
    referenceDescription('transfer_alpha_discrete_sRGB'),
    () => expectBrowserReference('transfer_alpha_discrete_sRGB'),
  );
  test(
    referenceDescription('transfer_alpha_discrete_linearRGB'),
    () => expectBrowserReference('transfer_alpha_discrete_linearRGB'),
  );
  test(
    referenceDescription('transfer_alpha_gamma_sRGB'),
    () => expectBrowserReference('transfer_alpha_gamma_sRGB'),
  );
  test(
    referenceDescription('transfer_alpha_gamma_linearRGB'),
    () => expectBrowserReference('transfer_alpha_gamma_linearRGB'),
  );
  test(
    referenceDescription('transfer_alpha_create_sRGB'),
    () => expectBrowserReference('transfer_alpha_create_sRGB'),
  );
  test(
    referenceDescription('transfer_alpha_create_linearRGB'),
    () => expectBrowserReference('transfer_alpha_create_linearRGB'),
  );
  test(
    referenceDescription('transfer_gamma_zero_sRGB'),
    () => expectBrowserReference('transfer_gamma_zero_sRGB'),
  );
  test(
    referenceDescription('transfer_gamma_zero_linearRGB'),
    () => expectBrowserReference('transfer_gamma_zero_linearRGB'),
  );
  test(
    referenceDescription('transfer_gamma_negative_sRGB'),
    () => expectBrowserReference('transfer_gamma_negative_sRGB'),
  );
  test(
    referenceDescription('transfer_gamma_negative_linearRGB'),
    () => expectBrowserReference('transfer_gamma_negative_linearRGB'),
  );
  test(
    referenceDescription('transfer_duplicate_sRGB'),
    () => expectBrowserReference('transfer_duplicate_sRGB'),
  );
  test(
    referenceDescription('transfer_duplicate_linearRGB'),
    () => expectBrowserReference('transfer_duplicate_linearRGB'),
  );
  test(
    referenceDescription('transfer_defaults_sRGB'),
    () => expectBrowserReference('transfer_defaults_sRGB'),
  );
  test(
    referenceDescription('transfer_defaults_linearRGB'),
    () => expectBrowserReference('transfer_defaults_linearRGB'),
  );
  test(referenceDescription('transfer_empty'), () => expectBrowserReference('transfer_empty'));
  test(
    referenceDescription('transfer_subregion'),
    () => expectBrowserReference('transfer_subregion'),
  );
  test(
    referenceDescription('transfer_zero_region'),
    () => expectBrowserReference('transfer_zero_region'),
  );
  test(referenceDescription('transfer_chain'), () => expectBrowserReference('transfer_chain'));

  for (final channel in <String>['R', 'G', 'B', 'A']) {
    for (final value in <int>[0, 1, 64, 84, 85, 127, 128, 170, 192, 254, 255]) {
      for (final type in <String>['table', 'discrete', 'linear', 'gamma']) {
        test('independent $channel $type at $value', () async {
          final double v = value / 255;
          final String attributes = switch (type) {
            'table' => 'tableValues="-1 2"',
            'discrete' => 'tableValues="0 .5 1"',
            'linear' => 'slope="-.5" intercept=".8"',
            'gamma' => 'amplitude=".8" exponent="2" offset=".1"',
            _ => throw StateError(type),
          };
          final double expected = (switch (type) {
            'table' => -1 + 3 * v,
            'discrete' => math.min((v * 3).floor(), 2) / 2,
            'linear' => -.5 * v + .8,
            'gamma' => .8 * v * v + .1,
            _ => throw StateError(type),
          }).clamp(0.0, 1.0);
          final source = channel == 'A'
              ? '<feFlood flood-color="gray" flood-opacity="$v"/>'
              : '<feFlood flood-color="rgb($value,$value,$value)"/>';
          final ui.Image image = await renderSvg(
            filterSvg(
              '$source<feComponentTransfer><feFunc$channel type="$type" $attributes/></feComponentTransfer>',
            ),
          );
          final Uint8List data = await pixels(image);
          image.dispose();
          expect(data[<String>['R', 'G', 'B', 'A'].indexOf(channel)], closeTo(expected * 255, 2));
        });
      }
    }
  }
  for (final type in <String>['table', 'discrete']) {
    for (final value in <String>['NaN', 'Infinity', 'bad', '1e100']) {
      test('invalid $type table value $value', () async {
        await expectLater(
          renderSvg(
            filterSvg(
              '<feComponentTransfer><feFuncR type="$type" tableValues="$value"/></feComponentTransfer>',
            ),
          ),
          throwsA(anything),
        );
      });
    }
  }
  for (final (String type, String attribute) in <(String, String)>[
    ('linear', 'slope'),
    ('linear', 'intercept'),
    ('gamma', 'amplitude'),
    ('gamma', 'exponent'),
    ('gamma', 'offset'),
  ]) {
    test('invalid $type $attribute', () async {
      await expectLater(
        renderSvg(
          filterSvg(
            '<feComponentTransfer><feFuncR type="$type" $attribute="NaN"/></feComponentTransfer>',
          ),
        ),
        throwsA(anything),
      );
    });
  }
  test('long tables retain precision between entries', () async {
    final String table = List<String>.generate(4096, (int i) => (i / 4095).toString()).join(' ');
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feFlood flood-color="rgb(37,37,37)"/><feComponentTransfer><feFuncR type="table" tableValues="$table"/></feComponentTransfer>',
      ),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[0], closeTo(37, 1));
  });
  test('oversized tables fail before allocating their texture', () async {
    final String table = List<String>.filled(4097, '0').join(' ');
    await expectLater(
      renderSvg(
        filterSvg(
          '<feComponentTransfer><feFuncR type="table" tableValues="$table"/></feComponentTransfer>',
        ),
      ),
      throwsA(anything),
    );
  });
  for (final child in <String>['<feFuncR type="wrong"/>', '<feFuncX/>']) {
    test('unsupported transfer function is diagnosed $child', () async {
      await expectLater(
        renderSvg(filterSvg('<feComponentTransfer>$child</feComponentTransfer>')),
        throwsA(anything),
      );
    });
  }
}
