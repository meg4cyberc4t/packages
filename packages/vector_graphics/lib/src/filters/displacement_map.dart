// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';

/// Samples the source at coordinates displaced by straight map channels.
FilterImage displacementMap(FilterContext context, VectorFilter primitive) {
  final Map<String, String> a = primitive.attributes;
  final FilterImage input = context.input(a['in']);
  final FilterImage map = context.input(a['in2']);
  final Rect bounds = context.subregion(primitive, input.region.expandToInclude(map.region));
  final double sx = checkedFilterFloat(
    context.primitiveNumber(a['scale'] ?? '0', horizontal: true),
  );
  final double sy = checkedFilterFloat(
    context.primitiveNumber(a['scale'] ?? '0', horizontal: false),
  );
  int channel(String name) {
    final int index = <String>['R', 'G', 'B', 'A'].indexOf(a[name] ?? 'A');
    if (index < 0) {
      throw FormatException('Invalid displacement $name: ${a[name]}');
    }
    return index;
  }

  final int cx = channel('xChannelSelector');
  final int cy = channel('yChannelSelector');
  final bool linear = context.linearColor(primitive);
  if (bounds.isEmpty || (sx == 0 && sy == 0)) {
    return context.record(bounds, (Canvas canvas) => canvas.drawPicture(input.picture));
  }
  if (input.region.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  // SourceGraphic is not clipped to the filter region before evaluation: pixels
  // just outside it can be displaced into the output. Intermediates are clipped.
  final Rect requestedDomain = context.isSource(input)
      ? Rect.fromLTRB(
          bounds.left - sx.abs() / 2,
          bounds.top - sy.abs() / 2,
          bounds.right + sx.abs() / 2,
          bounds.bottom + sy.abs() / 2,
        )
      : input.region;
  final double resolution = context.rasterScale;
  final domain = Rect.fromLTRB(
    (requestedDomain.left * resolution).floorToDouble() / resolution,
    (requestedDomain.top * resolution).floorToDouble() / resolution,
    (requestedDomain.right * resolution).ceilToDouble() / resolution,
    (requestedDomain.bottom * resolution).ceilToDouble() / resolution,
  );
  final Image source = context.sample(input, domain);
  final Image displacement = context.sample(map, bounds);
  return context.shade('displacement_map', bounds, (FragmentShader shader) {
    final parameters = <double>[
      domain.left,
      domain.top,
      domain.width,
      domain.height,
      source.width.toDouble(),
      source.height.toDouble(),
      sx,
      sy,
      cx.toDouble(),
      cy.toDouble(),
      if (linear) 1 else 0,
    ];
    for (var i = 0; i < parameters.length; i++) {
      shader.setFloat(i + 4, parameters[i]);
    }
    shader
      ..setImageSampler(0, source)
      ..setImageSampler(1, displacement);
  });
}
