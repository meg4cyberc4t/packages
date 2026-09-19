// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Blurs the input independently on each axis in the primitive's color space.
FilterImage gaussianBlur(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final List<double> values = FilterContext.numbers(primitive.attributes['stdDeviation'] ?? '0');
  if (values.isEmpty || values.length > 2) {
    throw const FormatException('stdDeviation requires one or two numbers');
  }
  final double sigmaX = context.primitiveNumber(values.first.toString(), horizontal: true);
  final double sigmaY = context.primitiveNumber(values.last.toString(), horizontal: false);
  final Rect bounds = context.subregion(primitive, input.region);
  final TileMode tileMode = switch (primitive.attributes['edgeMode'] ?? 'none') {
    'none' => TileMode.decal,
    'duplicate' => TileMode.clamp,
    'wrap' => TileMode.repeated,
    final String value => throw FormatException('Invalid feGaussianBlur edgeMode: $value'),
  };
  return context.record(bounds, (Canvas canvas) {
    if (sigmaX < 0 || sigmaY < 0 || (sigmaX == 0 && sigmaY == 0)) {
      canvas.drawPicture(input.picture);
      return;
    }
    canvas.saveLayer(
      input.region,
      Paint()
        ..imageFilter = context.inColorSpace(
          primitive,
          ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY, tileMode: tileMode),
        ),
    );
    // Define the complete input surface, including transparent space, so the
    // edge mode does not mistake a shape's own bounds for the input domain.
    canvas.drawRect(
      input.region,
      Paint()
        ..color = const Color(0x00000000)
        ..blendMode = BlendMode.src,
    );
    canvas.drawPicture(input.picture);
    canvas.restore();
  });
}
