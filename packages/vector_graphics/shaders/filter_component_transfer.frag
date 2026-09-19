// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"
#include "filter_data.glsl"

uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec4 uR;
uniform vec4 uG;
uniform vec4 uB;
uniform vec4 uA;
uniform float uLinear;
uniform vec2 uTableSize;
uniform sampler2D uInput;
uniform sampler2D uTable;
out vec4 fragColor;

float tableValue(float index, float row) {
  vec2 p = vec2(index * 2.0 + 0.5, row + 0.5);
  return filterFloat(texture(uTable, p / uTableSize).rgb,
      texture(uTable, (p + vec2(1.0, 0.0)) / uTableSize).rgb);
}

float transfer(float value, vec4 fn, float row) {
  if (fn.x < 0.5) return value;
  if (fn.x < 2.5) {
    float count = fn.y;
    if (count < 0.5) return value;
    if (fn.x < 1.5) {
      float position = value * (count - 1.0);
      float index = floor(position);
      return mix(tableValue(index, row), tableValue(min(index + 1.0, count - 1.0), row), position - index);
    }
    return tableValue(min(floor(value * count), count - 1.0), row);
  }
  if (fn.x < 3.5) return fn.y * value + fn.z;
  if (fn.y == 0.0) return fn.w;
  if (fn.z == 0.0) return fn.y + fn.w;
  if (value == 0.0 && fn.z < 0.0) return fn.y > 0.0 ? 1.0 : 0.0;
  return fn.y * pow(value, fn.z) + fn.w;
}

void main() {
  vec4 c = filterWorking(texture(uInput, (FlutterFragCoord().xy - uOrigin) / uSize), uLinear);
  vec4 v = vec4(c.a > 0.0 ? clamp(c.rgb / c.a, 0.0, 1.0) : vec3(0.0), c.a);
  v = clamp(vec4(transfer(v.r, uR, 0.0), transfer(v.g, uG, 1.0),
      transfer(v.b, uB, 2.0), transfer(v.a, uA, 3.0)), 0.0, 1.0);
  fragColor = filterOutput(vec4(v.rgb * v.a, v.a), uLinear);
}
