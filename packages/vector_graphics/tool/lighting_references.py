# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Independent scalar references for SVG lighting edge kernels and temporary grids.

Chrome ignores kernelUnitLength and clamps samples at the outer image edge. SVG
specifies distinct corner/edge kernels. Compute these exceptional cases without
using the Flutter implementation, then let Chrome interpolate the ordinary PNG.
"""
import base64
import math
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1] / 'test/filters/fixtures'
KX = [
    [0,0,0,0,-2,2,0,-1,1], [0,0,0,-2,0,2,-1,0,1], [0,0,0,-2,2,0,-1,1,0],
    [0,-1,1,0,-2,2,0,-1,1], [-1,0,1,-2,0,2,-1,0,1], [-1,1,0,-2,2,0,-1,1,0],
    [0,-1,1,0,-2,2,0,0,0], [-1,0,1,-2,0,2,0,0,0], [-1,1,0,-2,2,0,0,0,0],
]
FX = [2/3,1/3,2/3,1/2,1/4,1/2,2/3,1/3,2/3]


def unit(v):
    length = math.sqrt(sum(n*n for n in v))
    return [n/length for n in v] if length else [0,0,0]


def normal(grid, x, y, dx, dy, surface):
    w, h = len(grid[0]), len(grid)
    cx = 0 if x == 0 else 2 if x == w-1 else 1
    cy = 0 if y == 0 else 2 if y == h-1 else 1
    ix, iy = cy*3+cx, cx*3+cy
    gx = gy = 0
    for j in range(3):
        for i in range(3):
            px, py = x+i-1, y+j-1
            if 0 <= px < w and 0 <= py < h:
                gx += KX[ix][j*3+i]*grid[py][px]
                gy += KX[iy][i*3+j]*grid[py][px]
    return unit([-surface*gx*FX[ix]/dx,-surface*gy*FX[iy]/dy,1])


def illumination(kind, point, height):
    if kind == 'distant':
        return [.5,.5,math.sqrt(.5)], 1
    z = 96 if kind == 'spot' else 64
    direction = unit([64-point[0],48-point[1],z-height])
    if kind == 'point':
        return direction, 1
    axis = unit([0,16,-96])
    return direction, max(0,-sum(a*b for a,b in zip(direction,axis)))**4


def png(width, height, pixels):
    def chunk(name, data):
        return struct.pack('>I',len(data))+name+data+struct.pack('>I',zlib.crc32(name+data))
    stride = width*4
    raw = b''.join(b'\0'+bytes(pixels[y*stride:(y+1)*stride]) for y in range(height))
    return (b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,6,0,0,0))
            +chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))


def write_case(kind, name, dx, dy, ramp=False, mode="diffuse"):
    """White light with exponent one; scalar math is independent of GLSL."""
    w, h = int(128/dx), int(128/dy)
    def alpha(x,y):
        if ramp:
            return math.floor((x+.5)/128*255+.5)/255
        px, py = (x+.5)*dx, (y+.5)*dy
        return 1 if 24 <= px < 64 and 24 <= py < 88 else 128/255 if 64 <= px < 104 and 40 <= py < 104 else 0
    grid = [[alpha(x,y) for x in range(w)] for y in range(h)]
    surface = 32 if ramp else 1
    pixels = []
    for y in range(h):
        for x in range(w):
            n = normal(grid,x,y,dx,dy,surface)
            light, attenuation = illumination(kind,((x+.5)*dx,(y+.5)*dy),surface*grid[y][x])
            if mode == 'specular':
                light = unit([light[0],light[1],light[2]+1])
            v = max(0,min(1,sum(a*b for a,b in zip(n,light))*attenuation))
            byte = math.floor(v*255+.5)
            # PNG stores straight RGBA. Specular RGB and alpha are both v.
            pixels.extend([255,255,255,byte] if mode == 'specular' else [byte]*3+[255])
    data = base64.b64encode(png(w,h,pixels)).decode()
    (ROOT/f'{mode}_{kind}_{name}.reference.svg').write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">'
        f'<image width="128" height="128" preserveAspectRatio="none" href="data:image/png;base64,{data}"/></svg>')


def main():
    for mode in ['diffuse', 'specular']:
        for kind in ['distant','point','spot']:
            for name, dx, dy in [('kernel_x',2,1),('kernel_y',1,2),('kernel_four',4,4)]:
                write_case(kind,name,dx,dy,mode=mode)
            write_case(kind,'alpha_ramp',1,1,True,mode=mode)

if __name__ == '__main__':
    main()
