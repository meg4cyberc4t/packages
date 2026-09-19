// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"
#include "filter_data.glsl"

uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec2 uInputOrigin;
uniform vec2 uInputSize;
uniform vec2 uPixels;
uniform vec2 uStep;
uniform vec2 uOrder;
uniform vec2 uTarget;
uniform float uDivisor;
uniform float uBias;
uniform float uPreserve;
uniform float uEdge;
uniform float uLinear;
uniform vec2 uTableSize;
uniform float uKernelGrid;
uniform sampler2D uInput;
uniform sampler2D uTable;
out vec4 fragColor;
#include "filter_sample.glsl"

float kernelValue(float index) {
  vec2 p = vec2(index * 2.0 + 0.5, 0.5);
  return filterFloat(texture(uTable, p / uTableSize).rgb,
      texture(uTable, (p + vec2(1.0, 0.0)) / uTableSize).rgb);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 pos = (p - uInputOrigin) / uInputSize * uPixels;
  // Explicit kernel spacing evaluates at input pixel centers. A cropped
  // viewport must not introduce tiny interpolation weights at transparent
  // neighbors before preserveAlpha unpremultiplies their color.
  if (uKernelGrid > 0.5) pos = floor(pos) + vec2(0.5);
  vec4 sum = vec4(0.0);
  float count = uOrder.x * uOrder.y;
  for (int i = 0; i < 4096; i++) {
    if (float(i) >= count) break;
    vec2 offset = vec2(mod(float(i), uOrder.x), floor(float(i) / uOrder.x)) - uTarget;
    vec4 value = filterSample( pos + offset * uStep / uInputSize * uPixels, uPixels, uEdge, uLinear);
    if (uPreserve > 0.5 && value.a > 0.0) value.rgb /= value.a;
    float weight = kernelValue(count - float(i) - 1.0);
    sum += value * weight;
  }
  float alpha;
  vec3 color;
  if (uPreserve > 0.5) {
    alpha = filterSample( pos, uPixels, 0.0, 0.0).a;
    color = clamp(sum.rgb / uDivisor + uBias, 0.0, 1.0) * alpha;
  } else {
    alpha = clamp(sum.a / uDivisor + uBias, 0.0, 1.0);
    color = clamp(sum.rgb / uDivisor + uBias * alpha, vec3(0.0), vec3(alpha));
  }
  if (any(lessThan(p, uOrigin)) || any(greaterThan(p, uOrigin + uSize))) alpha = 0.0;
  fragColor = filterOutput(vec4(color, alpha), uLinear);
}
