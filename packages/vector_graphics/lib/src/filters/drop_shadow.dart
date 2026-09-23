// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'flood.dart';

/// Draws a colored, blurred, offset input alpha below the unchanged input.
FilterImage dropShadow(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final Rect bounds = context.subregion(primitive, input.region);
  final List<double> values = FilterContext.numbers(primitive.attributes['stdDeviation'] ?? '2');
  if (values.isEmpty || values.length > 2) {
    throw const FormatException('stdDeviation requires one or two numbers');
  }
  final double sx = context.primitiveNumber(values.first.toString(), horizontal: true);
  final double sy = context.primitiveNumber(values.last.toString(), horizontal: false);
  final double dx = context.primitiveNumber(primitive.attributes['dx'] ?? '2', horizontal: true);
  final double dy = context.primitiveNumber(primitive.attributes['dy'] ?? '2', horizontal: false);
  final Color color = floodColor(primitive);
  double toLinear(double c) =>
      c <= .04045 ? c / 12.92 : math.pow((c + .055) / 1.055, 2.4).toDouble();
  return context.recordColor(primitive, bounds, (Canvas canvas, bool linear) {
    final shadow = linear
        ? Color.from(
            alpha: color.a,
            red: toLinear(color.r),
            green: toLinear(color.g),
            blue: toLinear(color.b),
          )
        : color;
    final paint = Paint()..colorFilter = ColorFilter.mode(shadow, BlendMode.srcIn);
    if (sx >= 0 && sy >= 0 && (sx != 0 || sy != 0)) {
      paint.imageFilter = ImageFilter.blur(sigmaX: sx, sigmaY: sy, tileMode: TileMode.decal);
    }
    canvas.save();
    canvas.translate(dx, dy);
    canvas.saveLayer(input.region, paint);
    context.draw(canvas, input);
    canvas.restore();
    canvas.restore();
    context.drawInput(canvas, input, linear);
  });
}
