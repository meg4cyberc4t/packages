// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Maps the SVG/CSS blend modes to their native compositing equivalents.
BlendMode svgBlendMode(String value) => switch (value) {
  'normal' => BlendMode.srcOver,
  'multiply' => BlendMode.multiply,
  'screen' => BlendMode.screen,
  'darken' => BlendMode.darken,
  'lighten' => BlendMode.lighten,
  'overlay' => BlendMode.overlay,
  'color-dodge' => BlendMode.colorDodge,
  'color-burn' => BlendMode.colorBurn,
  'hard-light' => BlendMode.hardLight,
  'soft-light' => BlendMode.softLight,
  'difference' => BlendMode.difference,
  'exclusion' => BlendMode.exclusion,
  'hue' => BlendMode.hue,
  'saturation' => BlendMode.saturation,
  'color' => BlendMode.color,
  'luminosity' => BlendMode.luminosity,
  _ => throw FormatException('Invalid feBlend mode: $value'),
};

/// Blends `in` (source) over `in2` (backdrop) in the chosen color space.
FilterImage blend(FilterContext context, VectorFilter primitive) {
  final FilterImage source = context.input(primitive.attributes['in']);
  final FilterImage backdrop = context.input(primitive.attributes['in2']);
  final BlendMode mode = svgBlendMode(primitive.attributes['mode'] ?? 'normal');
  final Rect bounds = context.subregion(primitive, source.region.expandToInclude(backdrop.region));
  return context.recordColor(primitive, bounds, (Canvas canvas, bool linear) {
    context.drawInput(canvas, backdrop, linear);
    context.drawInput(canvas, source, linear, mode: mode);
  });
}
