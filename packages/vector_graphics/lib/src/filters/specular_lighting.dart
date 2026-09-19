// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';
import 'lighting.dart';

/// Computes a Blinn-Phong light map whose alpha is the largest color component.
FilterImage specularLighting(FilterContext context, VectorFilter primitive) {
  final double constant = checkedFilterFloat(
    FilterContext.number(primitive.attributes['specularConstant'] ?? '1'),
  );
  final double exponent = checkedFilterFloat(
    FilterContext.number(primitive.attributes['specularExponent'] ?? '1'),
  );
  if (constant < 0) {
    throw const FormatException('Specular constant must be nonnegative');
  }
  if (exponent < 1 || exponent > 128) {
    throw const FormatException('Specular exponent must be between 1 and 128');
  }
  return renderLighting(
    context,
    primitive,
    shaderName: 'specular_lighting',
    constant: constant,
    extraUniforms: <double>[exponent],
  );
}
