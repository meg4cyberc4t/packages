// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_shaders.dart';

void main() {
  test('shader diagnostic preserves asset, cause, and renderer guidance', () {
    final cause = UnsupportedError('runtime programs unavailable');
    final error = FilterShaderException('packages/vector_graphics/shaders/example.frag', cause);
    expect(error.cause, same(cause));
    expect(error.toString(), contains(error.asset));
    expect(error.toString(), contains(cause.toString()));
    expect(error.toString(), contains('both Skia and Impeller'));
    expect(error.toString(), contains('rebuild the application'));
    expect(error.toString(), contains('do not require the Impeller-only ImageFilter.shader'));
  });

  testWidgets('failed program loads notify all subscribers and remain retryable', (
    WidgetTester tester,
  ) async {
    final String prefix = FilterShaders.debugAssetPrefix;
    addTearDown(() => FilterShaders.debugAssetPrefix = prefix);
    FilterShaders.debugAssetPrefix = 'missing-filter-program/';
    await tester.runAsync(
      () => Future.wait(<Future<void>>[
        for (var i = 0; i < 2; i++)
          expectLater(FilterShaders.load(), throwsA(isA<FilterShaderException>())),
      ]),
    );
    FilterShaders.debugAssetPrefix = '';
    final FilterShaders shaders = (await tester.runAsync(FilterShaders.load))!;
    shaders.create('passthrough').dispose();
    expect(() => shaders.create('not-requested'), throwsStateError);
  });
}
