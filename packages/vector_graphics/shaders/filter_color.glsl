// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

vec3 filterLinear(vec3 rgb) {
  return mix(rgb / 12.92, pow((rgb + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), rgb));
}

vec3 filterSrgb(vec3 rgb) {
  return mix(rgb * 12.92, 1.055 * pow(rgb, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), rgb));
}

vec4 filterWorking(vec4 color, float linear) {
  if (linear < 0.5 || color.a <= 0.0) return color;
  return vec4(filterLinear(clamp(color.rgb / color.a, 0.0, 1.0)) * color.a, color.a);
}

vec4 filterOutput(vec4 color, float linear) {
  color = clamp(color, 0.0, 1.0);
  color.rgb = min(color.rgb, vec3(color.a));
  if (linear < 0.5 || color.a <= 0.0) return color;
  return vec4(filterSrgb(color.rgb / color.a) * color.a, color.a);
}
