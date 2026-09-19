// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"

uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec2 uInputOrigin;
uniform vec2 uInputSize;
uniform vec2 uPixels;
uniform vec2 uScale;
uniform vec2 uChannels;
uniform float uLinear;
uniform sampler2D uInput;
uniform sampler2D uMap;
out vec4 fragColor;
#include "filter_sample.glsl"

float channel(vec4 c, float selector) {
  if (selector < 0.5) return c.r;
  if (selector < 1.5) return c.g;
  if (selector < 2.5) return c.b;
  return c.a;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec4 map = filterWorking(texture(uMap, (p - uOrigin) / uSize), uLinear);
  if (map.a > 0.0) map.rgb = clamp(map.rgb / map.a, 0.0, 1.0);
  vec2 offset = uScale * (vec2(channel(map, uChannels.x), channel(map, uChannels.y)) - 0.5);
  vec2 pos = (p + offset - uInputOrigin) / uInputSize * uPixels;
  // The working color space affects only the map. Source colors stay sRGB and
  // remain premultiplied during bilinear interpolation, including at its border.
  fragColor = filterSample(pos, uPixels, 0.0, 0.0);
}
