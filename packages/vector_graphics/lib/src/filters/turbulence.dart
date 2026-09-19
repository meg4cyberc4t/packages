// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';
import 'float_texture.dart';

/// The deterministic Park-Miller sequence required by SVG 1.1 turbulence.
class SvgNoiseRandom {
  /// Truncates the seed and normalizes it to 1..2147483646.
  SvgNoiseRandom(double seed) {
    if (!seed.isFinite) {
      throw const FormatException('Invalid turbulence seed');
    }
    final integer = BigInt.from(seed);
    final maximum = BigInt.from(2147483646);
    _state = integer <= BigInt.zero
        ? ((-integer) % maximum + BigInt.one).toInt()
        : integer > maximum
        ? maximum.toInt()
        : integer.toInt();
  }
  late int _state;

  /// Advances the sequence without integer overflow on JavaScript backends.
  int next() {
    _state = 16807 * (_state % 127773) - 2836 * (_state ~/ 127773);
    if (_state <= 0) {
      _state += 2147483647;
    }
    return _state;
  }
}

/// Builds the SVG 1.1 gradient lattice (the version used by browser renderers).
List<List<double>> turbulenceTables(double seed) {
  final random = SvgNoiseRandom(seed);
  final permutation = List<int>.generate(256, (int i) => i);
  final gradients = List<List<double>>.generate(4, (int channel) {
    final values = <double>[];
    for (var i = 0; i < 256; i++) {
      final double x = (random.next() % 512 - 256) / 256;
      final double y = (random.next() % 512 - 256) / 256;
      final double length = math.sqrt(x * x + y * y);
      // The rare zero vector contributes zero, retaining the specified sequence.
      values.addAll(length == 0 ? <double>[0, 0] : <double>[x / length, y / length]);
    }
    return values;
  });
  for (var i = 255; i > 0; i--) {
    final int j = random.next() % 256;
    final int value = permutation[i];
    permutation[i] = permutation[j];
    permutation[j] = value;
  }
  return <List<double>>[
    permutation.map((int i) => i.toDouble()).toList(),
    for (final row in gradients)
      <double>[
        for (final i in permutation) ...<double>[row[i * 2], row[i * 2 + 1]],
      ],
  ];
}

/// Adjusts the base frequency by the smaller relative change for a seamless tile.
double stitchedFrequency(double frequency, double extent) {
  if (frequency == 0) {
    return 0;
  }
  final double low = (frequency * extent).floorToDouble() / extent;
  final double high = (frequency * extent).ceilToDouble() / extent;
  return low > 0 && frequency / low < high / frequency ? low : high;
}

/// Generates four independent noise channels and premultiplies the output.
FilterImage turbulence(FilterContext context, VectorFilter primitive) {
  final Map<String, String> a = primitive.attributes;
  final Rect tile = context.primitiveRegion(primitive, context.region);
  final Rect bounds = tile.intersect(context.region);
  final List<double> frequency = FilterContext.numbers(a['baseFrequency'] ?? '0');
  if (frequency.isEmpty || frequency.length > 2 || frequency.any((double v) => v < 0)) {
    throw const FormatException('Turbulence frequency requires one or two nonnegative numbers');
  }
  final double octaveValue = FilterContext.number(a['numOctaves'] ?? '1');
  if (octaveValue < 0 || octaveValue != octaveValue.truncateToDouble()) {
    throw const FormatException('Turbulence octaves must be a nonnegative integer');
  }
  // Below 8-bit output precision, further octaves cannot add useful detail.
  final int octaves = math.min(octaveValue, 9).toInt();
  final double seed = FilterContext.number(a['seed'] ?? '0');
  final String type = a['type'] ?? 'turbulence';
  if (type != 'turbulence' && type != 'fractalNoise') {
    throw FormatException('Invalid turbulence type: $type');
  }
  final String stitch = a['stitchTiles'] ?? 'noStitch';
  if (stitch != 'stitch' && stitch != 'noStitch') {
    throw FormatException('Invalid turbulence stitchTiles: $stitch');
  }
  final bool linear = context.linearColor(primitive);
  if (bounds.isEmpty) {
    return context.record(bounds, (Canvas canvas) {});
  }
  const double originX = 0;
  const double originY = 0;
  // baseFrequency is not a primitive length. Its spatial frequency remains in
  // user coordinates even when the primitive subregion uses objectBoundingBox.
  double fx = frequency.first;
  double fy = frequency.last;
  if (stitch == 'stitch') {
    fx = stitchedFrequency(fx, tile.width);
    fy = stitchedFrequency(fy, tile.height);
  }
  // Bound coordinates before float lattice indexing loses its integer precision.
  final double maxX = math.max((bounds.left - originX).abs(), (bounds.right - originX).abs()) + 1;
  final double maxY = math.max((bounds.top - originY).abs(), (bounds.bottom - originY).abs()) + 1;
  if (!fx.isFinite ||
      !fy.isFinite ||
      math.max(maxX * fx, maxY * fy) * math.pow(2, octaves) > 4194304) {
    throw const FormatException('Turbulence frequency exceeds precise shader coordinates');
  }
  if (bounds.width * context.rasterScale * bounds.height * context.rasterScale * octaves * 16 >
      64 * 1024 * 1024) {
    throw StateError('Turbulence exceeds the 64 million gradient sample budget');
  }
  final Image table = floatTexture(context, turbulenceTables(seed));
  final double tileWidth = (tile.width * fx).roundToDouble();
  final double tileHeight = (tile.height * fy).roundToDouble();
  return context.shade('turbulence', bounds, (FragmentShader shader) {
    final values = <double>[
      originX,
      originY,
      fx,
      fy,
      octaves.toDouble(),
      if (type == 'fractalNoise') 1 else 0,
      if (stitch == 'stitch') 1 else 0,
      tileWidth,
      tileHeight,
      ((tile.left - originX) * fx + tileWidth).floorToDouble(),
      ((tile.top - originY) * fy + tileHeight).floorToDouble(),
      if (linear) 1 else 0,
      table.width.toDouble(),
      table.height.toDouble(),
    ];
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(i + 4, checkedFilterFloat(values[i]));
    }
    shader.setImageSampler(0, table);
  });
}
