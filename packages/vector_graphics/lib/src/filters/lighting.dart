// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';

/// Validated light geometry shared by diffuse and specular lighting.
class FilterLight {
  FilterLight._(this.type, this.position, this.direction, this.exponent, this.cone);

  /// 0: distant, 1: point, 2: spot.
  final int type;

  /// Point/spot position, or distant unit direction.
  final List<double> position;

  /// Unit direction from a spot light toward its target.
  final List<double> direction;

  /// Spot attenuation exponent, distinct from surface shininess.
  final double exponent;

  /// Cosine of the limiting cone; -1 means no explicit cone.
  final double cone;

  /// Selects the first light child; an absent light produces no output.
  static FilterLight? read(FilterContext context, VectorFilter primitive) {
    final VectorFilter? child = primitive.children
        .where(
          (VectorFilter f) =>
              <String>['feDistantLight', 'fePointLight', 'feSpotLight'].contains(f.name),
        )
        .firstOrNull;
    if (child == null) {
      return null;
    }
    final Map<String, String> a = child.attributes;
    double number(String key, [String fallback = '0']) =>
        checkedFilterFloat(FilterContext.number(a[key] ?? fallback));
    if (child.name == 'feDistantLight') {
      final double azimuth = (number('azimuth') % 360) * math.pi / 180;
      final double elevation = (number('elevation') % 360) * math.pi / 180;
      return FilterLight._(
        0,
        <double>[
          math.cos(azimuth) * math.cos(elevation),
          math.sin(azimuth) * math.cos(elevation),
          math.sin(elevation),
        ],
        <double>[0, 0, 0],
        1,
        -1,
      );
    }
    double x(String key) => checkedFilterFloat(
      context.primitiveNumber(a[key] ?? '0', horizontal: true) +
          (context.usesObjectUnits ? context.objectBounds.left : 0),
    );
    double y(String key) => checkedFilterFloat(
      context.primitiveNumber(a[key] ?? '0', horizontal: false) +
          (context.usesObjectUnits ? context.objectBounds.top : 0),
    );
    double z(String key) => checkedFilterFloat(number(key) * lightingZScale(context));
    final position = <double>[x('x'), y('y'), z('z')];
    if (child.name == 'fePointLight') {
      return FilterLight._(1, position, <double>[0, 0, 0], 1, -1);
    }
    final double exponent = number('specularExponent', '1');
    if (exponent < 0) {
      throw const FormatException('Spot exponent must be nonnegative');
    }
    final direction = <double>[
      x('pointsAtX') - position[0],
      y('pointsAtY') - position[1],
      z('pointsAtZ') - position[2],
    ];
    final double extent = direction.fold<double>(0, (double p, double n) => math.max(p, n.abs()));
    if (extent != 0) {
      final double length = math.sqrt(
        direction.fold<double>(0, (double p, double n) => p + (n / extent) * (n / extent)),
      );
      for (var i = 0; i < 3; i++) {
        direction[i] = direction[i] / extent / length;
      }
    }
    final double cone = a['limitingConeAngle'] == null
        ? -1
        : math.cos((number('limitingConeAngle') % 360) * math.pi / 180);
    return FilterLight._(2, position, direction, exponent, cone);
  }
}

/// SVG's normalized diagonal defines the Z unit for object bounding boxes.
double lightingZScale(FilterContext context) => !context.usesObjectUnits
    ? 1
    : math.sqrt(
        (context.objectBounds.width * context.objectBounds.width +
                context.objectBounds.height * context.objectBounds.height) /
            2,
      );

/// Samples the alpha height field and records a lighting shader with owned inputs.
FilterImage renderLighting(
  FilterContext context,
  VectorFilter primitive, {
  required String shaderName,
  required double constant,
  List<double> extraUniforms = const <double>[],
}) {
  final Map<String, String> a = primitive.attributes;
  final FilterImage input = context.input(a['in']);
  final Rect bounds = context.subregion(primitive, input.region);
  final FilterLight? light = FilterLight.read(context, primitive);
  final double surface = checkedFilterFloat(FilterContext.number(a['surfaceScale'] ?? '1'));
  final bool linear = context.linearColor(primitive);
  final color = Color(int.parse(a['lighting-color-argb'] ?? '4294967295'));
  Size? kernel;
  if (a.containsKey('kernelUnitLength')) {
    final List<double> values = FilterContext.numbers(a['kernelUnitLength']!);
    if (values.isEmpty || values.length > 2) {
      throw const FormatException('Lighting kernelUnitLength requires one or two numbers');
    }
    final double x = checkedFilterFloat(
      context.primitiveNumber(values.first.toString(), horizontal: true),
    );
    final double y = checkedFilterFloat(
      context.primitiveNumber(values.last.toString(), horizontal: false),
    );
    if (x > 0 && y > 0) {
      kernel = Size(x, y);
    }
  }
  if (light == null || bounds.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  final Rect domain = input.region.isEmpty ? bounds : input.region;
  final Image source = context.sample(input, domain, pixelSize: kernel);
  final double dx = domain.width / source.width;
  final double dy = domain.height / source.height;
  checkedFilterFloat(surface.abs() * 8 / math.min(dx, dy));
  checkedFilterFloat(
    light.position.fold<double>(
      surface.abs() + domain.left.abs() + domain.top.abs() + domain.width + domain.height,
      (double p, double v) => p + v.abs(),
    ),
  );
  // Keep the temporary output on the input's grid. Cropping a primitive must
  // not move its sample centers or change the normals of visible pixels.
  final Rect rasterBounds = kernel == null
      ? bounds
      : FilterContext.alignToGrid(bounds, domain, Size(dx, dy));
  FilterImage result = context.shade(shaderName, rasterBounds, (FragmentShader shader) {
    final values = <double>[
      domain.left,
      domain.top,
      domain.width,
      domain.height,
      source.width.toDouble(),
      source.height.toDouble(),
      dx,
      dy,
      surface,
      constant,
      color.r,
      color.g,
      color.b,
      if (linear) 1 else 0,
      light.type.toDouble(),
      ...light.position,
      ...light.direction,
      light.exponent,
      light.cone,
      ...extraUniforms,
    ];
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(i + 4, checkedFilterFloat(values[i]));
    }
    shader.setImageSampler(0, source);
  }, rasterize: kernel == null);
  if (kernel != null) {
    // The SVG algorithm computes normals and lighting on the temporary grid,
    // then interpolates the resulting light map back to the output resolution.
    final Image filtered = context.sample(result, rasterBounds, pixelSize: Size(dx, dy));
    result = context.record(bounds, (Canvas canvas) {
      canvas.drawImageRect(
        filtered,
        Rect.fromLTWH(0, 0, filtered.width.toDouble(), filtered.height.toDouble()),
        rasterBounds,
        Paint()..filterQuality = FilterQuality.low,
      );
    });
  }
  return result;
}
