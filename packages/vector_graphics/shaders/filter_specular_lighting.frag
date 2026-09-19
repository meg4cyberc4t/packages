// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_lighting.glsl"
uniform float uExponent;
out vec4 fragColor;
void main() {
  vec2 p=FlutterFragCoord().xy;
  vec2 point=(p-uInputOrigin)/uInputSize*uPixels;
  vec3 normal=surfaceNormal(point);
  vec3 direction,color;
  lightAt(p,heightAt(point),direction,color);
  vec3 halfway=unitVector(direction+vec3(0.0,0.0,1.0));
  vec3 specular=clamp(uConstant*pow(max(dot(normal,halfway),0.0),uExponent)*color,0.0,1.0);
  // SVG defines these RGB components as premultiplied, with max(R,G,B) alpha.
  float alpha=max(specular.r,max(specular.g,specular.b));
  fragColor=filterOutput(vec4(specular,alpha),uLinear);
}
