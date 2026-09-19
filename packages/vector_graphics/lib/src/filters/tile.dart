// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Repeats the complete input subregion, including its transparent margins.
FilterImage tile(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final Rect bounds = context.subregion(primitive, context.region);
  if (input.region.isEmpty || bounds.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  final Image image = context.sample(input, input.region);
  final matrix = Float64List.fromList(<double>[
    input.region.width / image.width,
    0,
    0,
    0,
    0,
    input.region.height / image.height,
    0,
    0,
    0,
    0,
    1,
    0,
    input.region.left,
    input.region.top,
    0,
    1,
  ]);
  final shader = ImageShader(
    image,
    TileMode.repeated,
    TileMode.repeated,
    matrix,
    filterQuality: FilterQuality.low,
  );
  try {
    return context.record(bounds, (Canvas canvas) {
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = shader
          ..isAntiAlias = false,
      );
    });
  } finally {
    // The recorded display list keeps its own native shader reference.
    shader.dispose();
  }
}
