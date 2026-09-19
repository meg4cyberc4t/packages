// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'filter_context.dart';
import 'float_texture.dart';
import 'lighting.dart';

/// Computes an opaque Lambert diffuse light map from input alpha heights.
FilterImage diffuseLighting(FilterContext context, VectorFilter primitive) {
  final double constant = checkedFilterFloat(
    FilterContext.number(primitive.attributes['diffuseConstant'] ?? '1'),
  );
  if (constant < 0) {
    throw const FormatException('Diffuse constant must be nonnegative');
  }
  return renderLighting(context, primitive, shaderName: 'diffuse_lighting', constant: constant);
}
