// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Decode a big-endian IEEE float stored in RGB(first texel), R(second texel).
float filterFloat(vec3 first, vec3 second) {
  vec3 hi = floor(first * 255.0 + 0.5);
  float lo = floor(second.r * 255.0 + 0.5);
  float signValue = hi.r >= 128.0 ? -1.0 : 1.0;
  float exponent = mod(hi.r, 128.0) * 2.0 + floor(hi.g / 128.0);
  float mantissa = mod(hi.g, 128.0) * 65536.0 + hi.b * 256.0 + lo;
  if (exponent == 0.0) return signValue * exp2(-126.0) * (mantissa / 8388608.0);
  return signValue * exp2(exponent - 127.0) * (1.0 + mantissa / 8388608.0);
}
