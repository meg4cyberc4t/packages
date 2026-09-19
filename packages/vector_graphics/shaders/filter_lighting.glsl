// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#include "filter_color.glsl"
uniform vec2 uOrigin;
uniform vec2 uSize;
uniform vec2 uInputOrigin;
uniform vec2 uInputSize;
uniform vec2 uPixels;
uniform vec2 uStep;
uniform float uSurface;
uniform float uConstant;
uniform vec3 uColor;
uniform float uLinear;
uniform float uLightType;
uniform vec3 uLight;
uniform vec3 uDirection;
uniform float uSpotExponent;
uniform float uCone;
uniform sampler2D uInput;
#include "filter_sample.glsl"

vec3 unitVector(vec3 v) {
  float extent=max(max(abs(v.x),abs(v.y)),abs(v.z));
  if(extent==0.0) return vec3(0.0);
  v/=extent;
  return v*inversesqrt(dot(v,v));
}
float heightAt(vec2 point) {
  return filterSample(point,uPixels,0.0,0.0).a;
}
vec3 surfaceNormal(vec2 point) {
  // Each edge uses only existing neighbors. For example, the top-left kernel
  // has rows [-2,2] and [-1,1], multiplied by 2/(3*dx).
  vec2 before=step(vec2(1.0),point);
  vec2 after=step(point,uPixels-1.0);
  float left=-before.x,right=after.x,top=-before.y,bottom=after.y;
  float wyTop=before.y,wyBottom=after.y,wxLeft=before.x,wxRight=after.x;
  float l=heightAt(point+vec2(left,0.0)),r=heightAt(point+vec2(right,0.0));
  float t=heightAt(point+vec2(0.0,top)),b=heightAt(point+vec2(0.0,bottom));
  float tl=heightAt(point+vec2(left,top)),tr=heightAt(point+vec2(right,top));
  float bl=heightAt(point+vec2(left,bottom)),br=heightAt(point+vec2(right,bottom));
  float gx=(wyTop*(tr-tl)+2.0*(r-l)+wyBottom*(br-bl));
  float gy=(wxLeft*(bl-tl)+2.0*(b-t)+wxRight*(br-tr));
  float spanX=before.x+after.x,spanY=before.y+after.y;
  gx=spanX>0.0 ? gx*2.0/((2.0+wyTop+wyBottom)*spanX*uStep.x) : 0.0;
  gy=spanY>0.0 ? gy*2.0/((2.0+wxLeft+wxRight)*spanY*uStep.y) : 0.0;
  return unitVector(vec3(-uSurface*gx,-uSurface*gy,1.0));
}
void lightAt(vec2 p,float alpha,out vec3 direction,out vec3 color) {
  direction=uLightType<0.5 ? uLight : unitVector(uLight-vec3(p,uSurface*alpha));
  color=filterWorking(vec4(uColor,1.0),uLinear).rgb;
  if(uLightType>1.5) {
    float focus=-dot(direction,uDirection);
    if(focus<=0.0 || focus<uCone || dot(uDirection,uDirection)==0.0) {
      color=vec3(0.0);
    } else {
      float attenuation=pow(clamp(focus,0.0,1.0),uSpotExponent);
      if(uCone>=0.0) {
        // A narrow linear ramp avoids a hard cone edge. A zero-angle cone has
        // zero solid angle and contributes no light, including at its axis.
        attenuation*=uCone>=1.0 ? 0.0 : min((focus-uCone)/0.016,1.0);
      }
      color*=attenuation;
    }
  }
}
