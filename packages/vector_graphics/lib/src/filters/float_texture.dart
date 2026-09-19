// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'filter_context.dart';

/// Validates an SVG parameter before conversion to a GPU float.
double checkedFilterFloat(double value) {
  if (!value.isFinite || value.abs() > 3.402823466e38) {
    throw FormatException('Filter parameter must fit a finite shader float: $value');
  }
  return value;
}

/// Packs IEEE float bytes into two opaque RGB texels per entry.
///
/// This retains negative and out-of-range table values until interpolation,
/// unlike an ordinary color lookup texture. The context owns the returned image.
Image floatTexture(FilterContext context, List<List<double>> rows) {
  if (rows.isEmpty || rows.length > 16) {
    throw const FormatException('Float textures require 1..16 rows');
  }
  var count = 1;
  for (final row in rows) {
    count = math.max(count, row.length);
  }
  if (count > 4096) {
    throw const FormatException('Filter tables are limited to 4096 entries');
  }
  final bounds = Rect.fromLTWH(0, 0, count * 2.0, rows.length.toDouble());
  final bytes = ByteData(4);
  final paint = Paint()..isAntiAlias = false;
  final FilterImage data = context.record(bounds, (Canvas canvas) {
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        bytes.setFloat32(0, checkedFilterFloat(rows[y][x]));
        paint.color = Color(
          0xff000000 | bytes.getUint8(0) << 16 | bytes.getUint8(1) << 8 | bytes.getUint8(2),
        );
        canvas.drawRect(Rect.fromLTWH(x * 2.0, y.toDouble(), 1, 1), paint);
        paint.color = Color(0xff000000 | bytes.getUint8(3) << 16);
        canvas.drawRect(Rect.fromLTWH(x * 2.0 + 1, y.toDouble(), 1, 1), paint);
      }
    }
  });
  return context.sample(data, bounds, scale: 1);
}
