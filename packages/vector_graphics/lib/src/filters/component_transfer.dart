// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';

/// Applies independently selected straight-channel transfer functions to RGBA.
FilterImage componentTransfer(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final Rect bounds = context.subregion(primitive, input.region);
  final functions = <VectorFilter?>[null, null, null, null];
  for (final VectorFilter child in primitive.children) {
    final int index = <String>['feFuncR', 'feFuncG', 'feFuncB', 'feFuncA'].indexOf(child.name);
    if (index < 0) {
      throw FormatException('Invalid feComponentTransfer child: ${child.name}');
    }
    functions[index] = child;
  }
  var identity = true;
  final parameters = <double>[];
  final tables = <List<double>>[];
  for (final function in functions) {
    final Map<String, String> a = function?.attributes ?? const <String, String>{};
    double value(String name, String fallback) =>
        checkedFilterFloat(FilterContext.number(a[name] ?? fallback));
    switch (a['type'] ?? 'identity') {
      case 'identity':
        parameters.addAll(<double>[0, 0, 0, 0]);
        tables.add(<double>[]);
      case 'table':
      case 'discrete':
        identity = false;
        final List<double> table = FilterContext.numbers(a['tableValues'] ?? '');
        parameters.addAll(<double>[
          if (a['type'] == 'table') 1 else 2,
          table.length.toDouble(),
          0,
          0,
        ]);
        tables.add(table);
      case 'linear':
        identity &= value('slope', '1') == 1 && value('intercept', '0') == 0;
        parameters.addAll(<double>[3, value('slope', '1'), value('intercept', '0'), 0]);
        tables.add(<double>[]);
      case 'gamma':
        identity &=
            value('amplitude', '1') == 1 &&
            value('exponent', '1') == 1 &&
            value('offset', '0') == 0;
        parameters.addAll(<double>[
          4,
          value('amplitude', '1'),
          value('exponent', '1'),
          value('offset', '0'),
        ]);
        tables.add(<double>[]);
      default:
        throw FormatException('Invalid component transfer type: ${a['type']}');
    }
  }
  if (bounds.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  final bool linear = context.linearColor(primitive);
  if (identity) {
    return context.record(bounds, (Canvas canvas) => canvas.drawPicture(input.picture));
  }
  final Image source = context.sample(input, bounds);
  final Image table = floatTexture(context, tables);
  return context.shade('component_transfer', bounds, (FragmentShader shader) {
    for (var i = 0; i < parameters.length; i++) {
      shader.setFloat(4 + i, parameters[i]);
    }
    shader
      ..setFloat(20, linear ? 1 : 0)
      ..setFloat(21, table.width.toDouble())
      ..setFloat(22, table.height.toDouble())
      ..setImageSampler(0, source)
      ..setImageSampler(1, table);
  });
}
