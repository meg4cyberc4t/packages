// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uOrigin;
uniform vec2 uSize;
uniform sampler2D uInput;
out vec4 fragColor;

void main() {
  vec2 uv = (FlutterFragCoord().xy - uOrigin) / uSize;
  fragColor = texture(uInput, uv);
}
