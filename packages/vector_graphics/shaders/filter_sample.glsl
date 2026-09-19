// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Included after the uInput sampler declaration: SkSL forbids sampler arguments.
// Pixel-center sampling with explicit extension avoids the sampler's clamp
// behavior leaking opaque border pixels into a transparent SVG input domain.
vec4 filterTexel(vec2 p, vec2 size, float edge, float linear) {
  if (edge > 1.5) {
    p = mod(p, size);
  } else if (edge > 0.5) {
    p = clamp(p, vec2(0.0), size - 1.0);
  } else if (any(lessThan(p, vec2(0.0))) || any(greaterThanEqual(p, size))) {
    return vec4(0.0);
  }
  return filterWorking(texture(uInput, (p + 0.5) / size), linear);
}

vec4 filterSample(vec2 p, vec2 size, float edge, float linear) {
  vec2 base = floor(p - 0.5);
  vec2 f = p - 0.5 - base;
  return mix(
    mix(filterTexel( base, size, edge, linear),
        filterTexel( base + vec2(1.0, 0.0), size, edge, linear), f.x),
    mix(filterTexel( base + vec2(0.0, 1.0), size, edge, linear),
        filterTexel( base + 1.0, size, edge, linear), f.x), f.y);
}
