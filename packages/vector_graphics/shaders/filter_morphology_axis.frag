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
uniform vec2 uStep;
uniform float uRadius;
uniform float uDilate;
uniform float uLinear;
uniform sampler2D uInput;
out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec4 value = uDilate > 0.5 ? vec4(0.0) : vec4(1.0);
  for (int i = 0; i < 16385; i++) {
    if (float(i) > 2.0 * uRadius) break;
    vec2 uv = (p - uInputOrigin + (float(i) - uRadius) * uStep) / uInputSize;
    vec4 sampleColor = vec4(0.0);
    if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0) {
      sampleColor = filterWorking(texture(uInput, uv), uLinear);
    }
    value = uDilate > 0.5 ? max(value, sampleColor) : min(value, sampleColor);
  }
  // Keep the shared uniform prefix present in reflection after optimization.
  if (any(lessThan(p, uOrigin)) || any(greaterThan(p, uOrigin + uSize))) value = vec4(0.0);
  fragColor = filterOutput(value, uLinear);
}
