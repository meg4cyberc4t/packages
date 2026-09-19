// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'blend.dart';
import 'color_matrix.dart';
import 'component_transfer.dart';
import 'composite.dart';
import 'drop_shadow.dart';
import 'filter_context.dart';
import 'flood.dart';
import 'gaussian_blur.dart';
import 'merge.dart';
import 'morphology.dart';
import 'offset.dart';
import 'tile.dart';

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
    case 'feMerge':
      return merge(context, primitive);
    case 'feBlend':
      return blend(context, primitive);
    case 'feComposite':
      return composite(context, primitive);
    case 'feDropShadow':
      return dropShadow(context, primitive);
    case 'feMorphology':
      return morphology(context, primitive);
    case 'feComponentTransfer':
      return componentTransfer(context, primitive);
    case 'feTile':
      return tile(context, primitive);
    default:
      throw UnsupportedError('SVG filter primitive ${primitive.name} is not implemented');
  }
}
