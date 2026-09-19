// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import '../vector_image.dart';
import 'filter_context.dart';

/// Positions a preloaded raster, standalone SVG, or referenced SVG fragment.
FilterImage filterImage(FilterContext context, VectorFilter primitive) {
  final Map<String, String> a = primitive.attributes;
  final Rect placement = context.primitiveRegion(primitive, context.region);
  final Rect bounds = placement.intersect(context.region);
  final int? id = int.tryParse(a['vector-image-id'] ?? '');
  final VectorImage? image = context.images[id];
  if (image == null || image.size.isEmpty || placement.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  if (a['vector-image-fragment'] == 'true') {
    final double sx = context.usesObjectUnits ? context.objectBounds.width : 1;
    final double sy = context.usesObjectUnits ? context.objectBounds.height : 1;
    return context.record(bounds, (Canvas canvas) {
      image.draw(
        canvas,
        Rect.fromLTWH(placement.left, placement.top, image.size.width * sx, image.size.height * sy),
        clipSource: false,
      );
    });
  }
  final List<String> ratio = (a['preserveAspectRatio'] ?? 'xMidYMid meet').trim().split(
    RegExp(r'\s+'),
  );
  if (ratio.firstOrNull == 'defer') {
    ratio.removeAt(0);
  }
  if (ratio.isEmpty || ratio.length > 2) {
    throw const FormatException('Invalid feImage preserveAspectRatio');
  }
  final String align = ratio.first;
  final String sizing = ratio.length == 2 ? ratio.last : 'meet';
  if (sizing != 'meet' && sizing != 'slice') {
    throw FormatException('Invalid feImage meet/slice: $sizing');
  }
  var target = placement;
  if (align != 'none') {
    final RegExpMatch? match = RegExp(r'^x(Min|Mid|Max)Y(Min|Mid|Max)$').firstMatch(align);
    if (match == null) {
      throw FormatException('Invalid feImage alignment: $align');
    }
    final double scale = sizing == 'meet'
        ? math.min(placement.width / image.size.width, placement.height / image.size.height)
        : math.max(placement.width / image.size.width, placement.height / image.size.height);
    final double width = image.size.width * scale;
    final double height = image.size.height * scale;
    double alignFactor(String part) => part == 'Min'
        ? 0
        : part == 'Mid'
        ? .5
        : 1;
    target = Rect.fromLTWH(
      placement.left + (placement.width - width) * alignFactor(match[1]!),
      placement.top + (placement.height - height) * alignFactor(match[2]!),
      width,
      height,
    );
  }
  // Flutter drawImageRect can sample outside its source rectangle. Clamp the
  // slice explicitly to avoid bleeding pixels hidden beyond the cropped image.
  final Image? raster = image.raster;
  if (sizing == 'slice' && align != 'none' && raster != null) {
    final Rect visible = target.intersect(placement);
    final source = Rect.fromLTWH(
      (visible.left - target.left) * image.size.width / target.width,
      (visible.top - target.top) * image.size.height / target.height,
      visible.width * image.size.width / target.width,
      visible.height * image.size.height / target.height,
    );
    return context.shade('image', bounds, (FragmentShader shader) {
      final values = <double>[
        target.left,
        target.top,
        target.width,
        target.height,
        image.size.width,
        image.size.height,
        source.left,
        source.top,
        source.right,
        source.bottom,
      ];
      for (var i = 0; i < values.length; i++) {
        shader.setFloat(i + 4, values[i]);
      }
      shader.setImageSampler(0, raster);
    });
  }
  return context.record(bounds, (Canvas canvas) {
    image.draw(canvas, target, filterQuality: FilterQuality.low);
  });
}
