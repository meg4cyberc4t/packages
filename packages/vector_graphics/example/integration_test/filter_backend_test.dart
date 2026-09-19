// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import '../../test/filters/backend_test.dart' as backend;

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  backend.runFilterBackendTests(shaderPrefix: 'packages/vector_graphics/');
  testWidgets('measure first render and repeated heavy filter chains', (WidgetTester tester) async {
    final measurements = <String, Object?>{};
    for (final (String name, String primitives) in <(String, String)>[
      (
        'convolve-transfer',
        '<feConvolveMatrix kernelMatrix="1 2 1 2 4 2 1 2 1"/> '
            '<feComponentTransfer><feFuncR type="table" tableValues="-1 2"/></feComponentTransfer>',
      ),
      (
        'turbulence-displacement',
        '<feTurbulence numOctaves="4" baseFrequency=".07" result="noise"/> '
            '<feDisplacementMap in="SourceGraphic" in2="noise" scale="8"/>',
      ),
      ('one-axis-morphology', '<feMorphology radius="0 8" operator="dilate"/>'),
    ]) {
      final Uint8List bytes = encodeSvg(
        xml:
            '<svg width="128" height="128"><defs><filter id="f" '
            'filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128">$primitives</filter></defs> '
            '<circle cx="64" cy="64" r="45" fill="#80b040" filter="url(#f)"/></svg>',
        debugName: name,
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      );
      final int before = ProcessInfo.currentRss;
      final watch = Stopwatch()..start();
      final PictureInfo info = await decodeVectorGraphics(
        bytes.buffer.asByteData(),
        locale: null,
        textDirection: ui.TextDirection.ltr,
        clipViewbox: true,
        filterRasterScale: 4,
        loader: AssetBytesLoader(name),
      );
      final int decodeUs = watch.elapsedMicroseconds;
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
        ..scale(4)
        ..drawPicture(info.picture);
      final ui.Picture scaled = recorder.endRecording();
      final ui.Image first = await scaled.toImage(512, 512);
      await first.toByteData(); // Include completion of GPU work and readback.
      final int firstRenderUs = watch.elapsedMicroseconds - decodeUs;
      first.dispose();
      scaled.dispose();
      final result = <String, Object?>{
        'decode_us': decodeUs,
        'first_render_and_readback_us': firstRenderUs,
        'process_rss_after_decode': ProcessInfo.currentRss,
        'process_rss_delta': ProcessInfo.currentRss - before,
      };
      final tick = ValueNotifier<int>(0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: CustomPaint(
              size: const Size(512, 512),
              painter: _FilterPainter(info.picture, tick),
            ),
          ),
        ),
      );
      await binding.watchPerformance(() async {
        for (var frame = 0; frame < 120; frame++) {
          tick.value++;
          await tester.pump(const Duration(milliseconds: 16));
        }
      }, reportKey: name);
      result['frames'] = binding.reportData![name];
      measurements[name] = result;
      await tester.pumpWidget(const SizedBox());
      tick.dispose();
      info.picture.dispose();
    }
    binding.reportData!['filter_measurements'] = measurements;
    // Also retained by flutter test's captured stdout for local runs.
    debugPrint('SVG_FILTER_MEASUREMENTS ${jsonEncode(measurements)}');
  });
}

class _FilterPainter extends CustomPainter {
  _FilterPainter(this.picture, this.tick) : super(repaint: tick);
  final ui.Picture picture;
  final ValueNotifier<int> tick;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate((tick.value % 2).toDouble(), 0);
    canvas.scale(4);
    canvas.drawPicture(picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FilterPainter oldDelegate) => oldDelegate.picture != picture;
}
