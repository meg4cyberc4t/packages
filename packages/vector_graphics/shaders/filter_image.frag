// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"
uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec2 uTargetOrigin;
uniform vec2 uTargetSize;
uniform vec2 uPixels;
uniform vec4 uCrop;
uniform sampler2D uInput;
out vec4 fragColor;
#include "filter_sample.glsl"
void main() {
  vec2 p = (FlutterFragCoord().xy - uTargetOrigin) / uTargetSize * uPixels;
  vec2 middle = (uCrop.xy + uCrop.zw) * 0.5;
  p = clamp(p, min(uCrop.xy + 0.5, middle), max(uCrop.zw - 0.5, middle));
  fragColor = filterSample(p, uPixels, 1.0, 0.0);
}
