// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_shaders.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';

void main() {
  testWidgets('missing shader fails all subscribers, reaches errorBuilder, and is retryable', (
    WidgetTester tester,
  ) async {
    final String originalPrefix = FilterShaders.debugAssetPrefix;
    addTearDown(() => FilterShaders.debugAssetPrefix = originalPrefix);
    FilterShaders.debugAssetPrefix = 'missing-svg-filter-assets/';
    await tester.runAsync(() async {
      final Future<FilterShaders> first = FilterShaders.load(), second = FilterShaders.load();
      await Future.wait(<Future<void>>[
        for (final Future<FilterShaders> pending in <Future<FilterShaders>>[first, second])
          expectLater(
            pending,
            throwsA(
              isA<FilterShaderException>()
                  .having(
                    (FilterShaderException e) => e.asset,
                    'asset',
                    'missing-svg-filter-assets/shaders/filter_passthrough.frag',
                  )
                  .having((FilterShaderException e) => e.cause, 'cause', isNotNull),
            ),
          ),
      ]);
    });

    final Uint8List data = encodeSvg(
      xml: filterSvg('<feComposite operator="arithmetic" k2=".5"/>'),
      debugName: 'shader failure',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    final loader = _Loader(data.buffer.asByteData());
    Object? diagnostic;
    Widget picture() => Directionality(
      textDirection: TextDirection.ltr,
      child: VectorGraphic(
        loader: loader,
        errorBuilder: (BuildContext context, Object error, StackTrace stack) {
          diagnostic = error;
          return const Text('shader unavailable');
        },
      ),
    );
    await tester.pumpWidget(picture());
    await tester.pumpAndSettle();
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    expect(find.text('shader unavailable'), findsOneWidget);
    expect(diagnostic.toString(), contains('missing-svg-filter-assets/'));
    expect(diagnostic.toString(), contains('both Skia and Impeller'));
    expect(tester.takeException(), isNull);
    expect(debugGetPendingDecodeTasks, isEmpty);

    await tester.pumpWidget(const SizedBox());
    FilterShaders.debugAssetPrefix = '';
    await tester.pumpWidget(picture());
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    expect(find.text('shader unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(debugGetPendingDecodeTasks, isEmpty);
    final FilterShaders recovered = (await tester.runAsync(FilterShaders.load))!;
    final FilterShaders cached = (await tester.runAsync(FilterShaders.load))!;
    cached.create('passthrough').dispose();
    final ui.FragmentShader shader = recovered.create('passthrough');
    shader.dispose();
    expect(() => recovered.create('unknown'), throwsStateError);
  });
}

class _Loader extends BytesLoader {
  const _Loader(this.data);
  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async => data;
}
