// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Computes per-channel minima or maxima over a rectangular neighborhood.
FilterImage morphology(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final Rect bounds = context.subregion(primitive, input.region);
  final List<double> values = FilterContext.numbers(primitive.attributes['radius'] ?? '0');
  if (values.isEmpty || values.length > 2) {
    throw const FormatException('Morphology radius requires one or two numbers');
  }
  final double rx = context.primitiveNumber(values.first.toString(), horizontal: true);
  final double ry = context.primitiveNumber(values.last.toString(), horizontal: false);
  if (!rx.isFinite || !ry.isFinite || rx.abs() > 3.402823466e38 || ry.abs() > 3.402823466e38) {
    throw const FormatException('Morphology radii must fit finite renderer floats');
  }
  final String operator = primitive.attributes['operator'] ?? 'erode';
  if (operator != 'erode' && operator != 'dilate') {
    throw FormatException('Invalid feMorphology operator: $operator');
  }
  if ((rx == 0 && ry > 0) || (ry == 0 && rx > 0)) {
    if (bounds.isEmpty) {
      return context.record(bounds, (Canvas canvas) {});
    }
    final Image image = context.sample(input, context.region);
    final horizontal = ry == 0;
    final double extent = horizontal ? context.region.width : context.region.height;
    final int pixels = horizontal ? image.width : image.height;
    final radius = horizontal ? rx : ry;
    final int steps = radius >= extent ? pixels : (radius * pixels / extent).floor();
    if (image.width * image.height * (2 * steps + 1) > 64 * 1024 * 1024) {
      throw StateError('One-axis morphology exceeds the 64 million sample budget');
    }
    return context.shade('morphology_axis', bounds, (FragmentShader shader) {
      shader
        ..setFloat(4, context.region.left)
        ..setFloat(5, context.region.top)
        ..setFloat(6, context.region.width)
        ..setFloat(7, context.region.height)
        ..setFloat(8, horizontal ? extent / pixels : 0)
        ..setFloat(9, horizontal ? 0 : extent / pixels)
        ..setFloat(10, steps.toDouble())
        ..setFloat(11, operator == 'dilate' ? 1 : 0)
        ..setFloat(12, context.linearColor(primitive) ? 1 : 0)
        ..setImageSampler(0, image);
    });
  }
  if (rx < 0 || ry < 0 || (rx == 0 && ry == 0)) {
    return context.record(bounds, (Canvas canvas) => canvas.drawPicture(input.picture));
  }
  return context.recordColor(primitive, bounds, (Canvas canvas, bool linear) {
    final operation = operator == 'erode'
        ? ImageFilter.erode(radiusX: rx, radiusY: ry)
        : ImageFilter.dilate(radiusX: rx, radiusY: ry);
    canvas.saveLayer(input.region, Paint()..imageFilter = operation);
    canvas.drawRect(
      input.region,
      Paint()
        ..color = const Color(0x00000000)
        ..blendMode = BlendMode.src,
    );
    context.drawInput(canvas, input, linear);
    canvas.restore();
  });
}
