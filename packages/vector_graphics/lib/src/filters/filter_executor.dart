// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'color_matrix.dart';
import 'filter_context.dart';
import 'flood.dart';
import 'gaussian_blur.dart';
import 'offset.dart';

/// Evaluates a definition in document order, preserving named intermediate results.
FilterImage executeFilter(FilterContext context) {
  if (context.region.isEmpty || context.definition.children.isEmpty) {
    return context.record(Rect.zero, (Canvas canvas) {});
  }
  for (final VectorFilter primitive in context.definition.children) {
    context.publish(primitive, executePrimitive(context, primitive));
  }
  return context.previous;
}

/// Dispatches one primitive. Each supported operation has a separate implementation.
FilterImage executePrimitive(FilterContext context, VectorFilter primitive) {
  switch (primitive.name) {
    case 'feOffset':
      return offset(context, primitive);
    case 'feColorMatrix':
      return colorMatrix(context, primitive);
    case 'feFlood':
      return flood(context, primitive);
    case 'feGaussianBlur':
      return gaussianBlur(context, primitive);
    default:
      throw UnsupportedError('SVG filter primitive ${primitive.name} is not implemented');
  }
}
