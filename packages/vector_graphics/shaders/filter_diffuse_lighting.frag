// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_lighting.glsl"
// Diffuse output is opaque even over transparent parts of the height field.
out vec4 fragColor;
void main() {
  vec2 p=FlutterFragCoord().xy;
  vec2 point=(p-uInputOrigin)/uInputSize*uPixels;
  vec3 normal=surfaceNormal(point);
  vec3 direction,color;
  lightAt(p,heightAt(point),direction,color);
  vec3 diffuse=clamp(uConstant*max(dot(normal,direction),0.0)*color,0.0,1.0);
  fragColor=filterOutput(vec4(diffuse,1.0),uLinear);
}
