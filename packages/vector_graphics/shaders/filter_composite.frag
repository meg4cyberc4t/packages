// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"

uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec4 uK;
uniform float uLinear;
uniform sampler2D uSource;
uniform sampler2D uBackdrop;
out vec4 fragColor;

void main() {
  vec2 uv = (FlutterFragCoord().xy - uOrigin) / uSize;
  vec4 s = filterWorking(texture(uSource, uv), uLinear);
  vec4 b = filterWorking(texture(uBackdrop, uv), uLinear);
  fragColor = filterOutput(uK.x * s * b + uK.y * s + uK.z * b + uK.w, uLinear);
}
