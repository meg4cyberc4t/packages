// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';

/// Combines neighboring pixels with a reversed, possibly asymmetric kernel.
FilterImage convolveMatrix(FilterContext context, VectorFilter primitive) {
  final Map<String, String> a = primitive.attributes;
  final FilterImage input = context.input(a['in']);
  final Rect bounds = context.subregion(primitive, input.region);
  final List<double> order = FilterContext.numbers(a['order'] ?? '3');
  if (order.isEmpty || order.length > 2 || order.any((double v) => v < 1 || v >= 65)) {
    throw const FormatException('Convolution order requires one or two values in [1, 65)');
  }
  final int columns = order.first.toInt();
  final int rows = order.last.toInt();
  final List<double> kernel = FilterContext.numbers(a['kernelMatrix'] ?? '');
  if (kernel.length != columns * rows) {
    return context.record(bounds, (Canvas canvas) => canvas.drawPicture(input.picture));
  }
  int target(String name, int order) {
    if (a[name] == null) {
      return order ~/ 2;
    }
    final int? value = int.tryParse(a[name]!);
    if (value == null || value < 0 || value >= order) {
      throw FormatException('Invalid convolution $name: ${a[name]}');
    }
    return value;
  }

  final int tx = target('targetX', columns);
  final int ty = target('targetY', rows);
  final double sum = kernel.fold(0, (double a, double b) => a + checkedFilterFloat(b));
  double divisor = FilterContext.number(a['divisor'] ?? '0');
  if (divisor == 0) {
    divisor = sum == 0 ? 1 : sum;
  }
  checkedFilterFloat(divisor);
  // A nonzero double may underflow to zero when passed to the renderer.
  if (divisor.abs() < 1.175494351e-38) {
    throw const FormatException('Convolution divisor must be a normal nonzero float');
  }
  final double bias = checkedFilterFloat(FilterContext.number(a['bias'] ?? '0'));
  final int edge = <String>['none', 'duplicate', 'wrap'].indexOf(a['edgeMode'] ?? 'duplicate');
  if (edge < 0) {
    throw FormatException('Invalid convolution edgeMode: ${a['edgeMode']}');
  }
  final String preserve = a['preserveAlpha'] ?? 'false';
  if (preserve != 'true' && preserve != 'false') {
    throw FormatException('Invalid convolution preserveAlpha: $preserve');
  }
  Size? pixelSize;
  if (a['kernelUnitLength'] != null) {
    final List<double> values = FilterContext.numbers(a['kernelUnitLength']!);
    if (values.isEmpty || values.length > 2) {
      throw const FormatException('kernelUnitLength requires one or two numbers');
    }
    final double dx = checkedFilterFloat(
      context.primitiveNumber(values.first.toString(), horizontal: true),
    );
    final double dy = checkedFilterFloat(
      context.primitiveNumber(values.last.toString(), horizontal: false),
    );
    if (dx > 0 && dy > 0) {
      pixelSize = Size(dx, dy);
    }
  }
  final bool linear = context.linearColor(primitive);
  if (bounds.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  final Rect domain = input.region.isEmpty ? bounds : input.region;
  final Image image = context.sample(input, domain, pixelSize: pixelSize);
  final step = Size(domain.width / image.width, domain.height / image.height);
  final Rect rasterBounds = pixelSize == null
      ? bounds
      : FilterContext.alignToGrid(bounds, domain, step);
  final double outputPixels = pixelSize == null
      ? rasterBounds.width * rasterBounds.height * context.rasterScale * context.rasterScale
      : (rasterBounds.width / step.width).roundToDouble() *
            (rasterBounds.height / step.height).roundToDouble();
  if (!outputPixels.isFinite || outputPixels * kernel.length > 64 * 1024 * 1024) {
    throw StateError('Convolution exceeds the 64 million sample budget');
  }
  final Image table = floatTexture(context, <List<double>>[kernel]);
  final FilterImage output = context.shade('convolve_matrix', rasterBounds, (
    FragmentShader shader,
  ) {
    final parameters = <double>[
      domain.left,
      domain.top,
      domain.width,
      domain.height,
      image.width.toDouble(),
      image.height.toDouble(),
      domain.width / image.width,
      domain.height / image.height,
      columns.toDouble(),
      rows.toDouble(),
      tx.toDouble(),
      ty.toDouble(),
      divisor,
      bias,
      if (preserve == 'true') 1 else 0,
      edge.toDouble(),
      if (linear) 1 else 0,
      table.width.toDouble(),
      table.height.toDouble(),
      if (pixelSize != null) 1 else 0,
    ];
    for (var i = 0; i < parameters.length; i++) {
      shader.setFloat(i + 4, parameters[i]);
    }
    shader
      ..setImageSampler(0, image)
      ..setImageSampler(1, table);
  }, rasterize: pixelSize == null);
  if (pixelSize == null) {
    return output;
  }
  // Explicit kernel spacing defines a temporary pixel grid. Finish the
  // convolution on that grid before interpolating back to the output picture.
  final Image resampled = context.sample(output, rasterBounds, pixelSize: step);
  return context.record(bounds, (Canvas canvas) {
    canvas.drawImageRect(
      resampled,
      Rect.fromLTWH(0, 0, resampled.width.toDouble(), resampled.height.toDouble()),
      rasterBounds,
      Paint()..filterQuality = FilterQuality.low,
    );
  });
}
