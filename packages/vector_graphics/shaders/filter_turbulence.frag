// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#version 460 core
#include <flutter/runtime_effect.glsl>
#include "filter_color.glsl"
#include "filter_data.glsl"
uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec2 uCoordinates;
uniform vec2 uFrequency;
uniform float uOctaves;
uniform float uFractal;
uniform float uStitch;
uniform vec2 uTile;
uniform vec2 uWrap;
uniform float uLinear;
uniform vec2 uTableSize;
uniform sampler2D uTable;
out vec4 fragColor;

float value(float index, float row) {
  vec2 p=vec2(index*2.0+0.5,row+0.5);
  return filterFloat(texture(uTable,p/uTableSize).rgb,
    texture(uTable,(p+vec2(1.0,0.0))/uTableSize).rgb);
}
float gradient(float index,float channel,vec2 offset) {
  float i=mod(index,256.0)*2.0;
  return dot(vec2(value(i,channel+1.0),value(i+1.0,channel+1.0)),offset);
}
vec4 noise(vec2 p,vec2 tile,vec2 wrap) {
  vec2 base=floor(p);
  vec2 f=p-base;
  vec4 lattice=vec4(base,base+1.0);
  if (uStitch>0.5) {
    lattice-=step(wrap.xyxy,lattice)*tile.xyxy;
  }
  // Lookup values are integers. Round away float reconstruction error before
  // modulo indexing; 255.99998 would otherwise address the wrong end of a row.
  float left=floor(value(mod(lattice.x,256.0),0.0)+0.5);
  float right=floor(value(mod(lattice.z,256.0),0.0)+0.5);
  vec4 indices=vec4(left+lattice.y,right+lattice.y,left+lattice.w,right+lattice.w);
  vec2 blend=f*f*(3.0-2.0*f);
  vec4 result=vec4(0.0);
  for (int c=0; c<4; c++) {
    float row=float(c);
    float top=mix(gradient(indices.x,row,f),gradient(indices.y,row,f-vec2(1.0,0.0)),blend.x);
    float bottom=mix(gradient(indices.z,row,f-vec2(0.0,1.0)),gradient(indices.w,row,f-1.0),blend.x);
    result[c]=mix(top,bottom,blend.y);
  }
  return result;
}
void main() {
  // Preserve the half-unit phase used by SVG browser renderers in local space.
  vec2 p=(FlutterFragCoord().xy + 0.5 - uCoordinates)*uFrequency;
  vec2 tile=uTile,wrap=uWrap;
  vec4 sum=vec4(0.0);
  float amplitude=1.0;
  for(int octave=0; octave<9; octave++) {
    if(float(octave)>=uOctaves) break;
    vec4 n=noise(p,tile,wrap);
    sum+=(uFractal>0.5?n:abs(n))*amplitude;
    p*=2.0; tile*=2.0; wrap*=2.0; amplitude*=0.5;
  }
  if(uFractal>0.5) sum=sum*0.5+0.5;
  sum=clamp(sum,0.0,1.0);
  fragColor=filterOutput(vec4(sum.rgb*sum.a,sum.a),uLinear);
}
