// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Composites two inputs using Porter-Duff or premultiplied arithmetic.
FilterImage composite(FilterContext context, VectorFilter primitive) {
  final FilterImage source = context.input(primitive.attributes['in']);
  final FilterImage backdrop = context.input(primitive.attributes['in2']);
  final Rect bounds = context.subregion(primitive, source.region.expandToInclude(backdrop.region));
  final String operator = primitive.attributes['operator'] ?? 'over';
  if (operator == 'arithmetic') {
    final coefficients = <double>[
      for (var i = 1; i <= 4; i++) FilterContext.number(primitive.attributes['k$i'] ?? '0'),
    ];
    if (coefficients.any((double value) => value.abs() > 3.402823466e38)) {
      throw const FormatException('Arithmetic coefficients must fit a finite shader float');
    }
    if (bounds.isEmpty) {
      return context.record(bounds, (Canvas canvas) {});
    }
    final Image s = context.sample(source, bounds);
    final Image b = context.sample(backdrop, bounds);
    return context.shade('composite', bounds, (FragmentShader shader) {
      for (var i = 0; i < 4; i++) {
        shader.setFloat(4 + i, coefficients[i]);
      }
      shader
        ..setFloat(8, context.linearColor(primitive) ? 1 : 0)
        ..setImageSampler(0, s)
        ..setImageSampler(1, b);
    });
  }
  final BlendMode mode = switch (operator) {
    'over' => BlendMode.srcOver,
    'in' => BlendMode.srcIn,
    'out' => BlendMode.srcOut,
    'atop' => BlendMode.srcATop,
    'xor' => BlendMode.xor,
    'lighter' => BlendMode.plus,
    _ => throw FormatException('Invalid feComposite operator: $operator'),
  };
  return context.recordColor(primitive, bounds, (Canvas canvas, bool linear) {
    context.drawInput(canvas, backdrop, linear);
    context.drawInput(canvas, source, linear, mode: mode);
  });
}
