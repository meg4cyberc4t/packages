# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Independent scalar SVG 1.1 oracle for nonzero-origin stitched turbulence.

Chrome passes only tile size to Skia, omitting tile origin. Generate these four
references from the published scalar equations; every other noise reference is
rendered directly by Chrome. No code or output from the Flutter implementation
is imported. The optional --samples writes numeric oracle data for shader tests.
"""
import base64
from functools import lru_cache
import json
import math
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1] / 'test/filters'


@lru_cache(maxsize=32)
def lattice(seed):
    state = int(seed)
    state = (-state % 2147483646) + 1 if state <= 0 else min(state, 2147483646)
    def rand():
        nonlocal state
        state = state * 16807 % 2147483647
        return state
    vectors = []
    for _ in range(4):
        row = []
        for _ in range(256):
            x, y = rand() % 512 - 256, rand() % 512 - 256
            length = math.hypot(x, y)
            row.append((x / length, y / length) if length else (0, 0))
        vectors.append(row)
    indices = list(range(256))
    for i in range(255, 0, -1):
        j = rand() % 256
        indices[i], indices[j] = indices[j], indices[i]
    return indices, vectors


def frequency(value, extent):
    if not value:
        return 0
    low = math.floor(value * extent) / extent
    high = math.ceil(value * extent) / extent
    return low if low and value / low < high / value else high


def rgba(seed, point, freq, octaves, fractal, tile=None):
    indices, vectors = lattice(seed)
    fx, fy = freq
    if tile:
        x, y, w, h = tile
        fx, fy = frequency(fx, w), frequency(fy, h)
        size = [round(w * fx), round(h * fy)]
        wrap = [math.floor(x * fx + size[0]), math.floor(y * fy + size[1])]
    sums = [0.] * 4
    px, py = point[0] * fx, point[1] * fy
    for octave in range(octaves):
        ix, iy = math.floor(px), math.floor(py)
        dx, dy = px - ix, py - iy
        blend = [dx * dx * (3 - 2 * dx), dy * dy * (3 - 2 * dy)]
        for channel in range(4):
            dots = []
            for oy in range(2):
                for ox in range(2):
                    cx, cy = ix + ox, iy + oy
                    if tile:
                        if cx >= wrap[0]: cx -= size[0]
                        if cy >= wrap[1]: cy -= size[1]
                    index = indices[(indices[cx % 256] + cy) % 256]
                    gx, gy = vectors[channel][index]
                    dots.append(gx * (dx - ox) + gy * (dy - oy))
            top = dots[0] * (1 - blend[0]) + dots[1] * blend[0]
            bottom = dots[2] * (1 - blend[0]) + dots[3] * blend[0]
            n = top * (1 - blend[1]) + bottom * blend[1]
            sums[channel] += (n if fractal else abs(n)) / 2 ** octave
        px *= 2
        py *= 2
        if tile:
            size = [v * 2 for v in size]
            wrap = [v * 2 for v in wrap]
    return [min(1, max(0, (v + 1) / 2 if fractal else v)) for v in sums]


def png(pixels):
    def chunk(name, data):
        return struct.pack('>I', len(data)) + name + data + struct.pack('>I', zlib.crc32(name + data))
    raw = b''.join(b'\0' + bytes(pixels[y * 512:(y + 1) * 512]) for y in range(128))
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB',128,128,8,6,0,0,0))
            + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))


def main():
    for kind in ['turbulence', 'fractalNoise']:
        for name, tile in [('subregion_stitch',(16,24,64,48)), ('clipped_stitch',(-16,-24,80,72))]:
            pixels = []
            for y in range(128):
                for x in range(128):
                    inside = tile[0] <= x < tile[0]+tile[2] and tile[1] <= y < tile[1]+tile[3]
                    color = rgba(0,(x+1,y+1),(.073,.043),1,kind=='fractalNoise',tile) if inside else [0]*4
                    pixels.extend(int(v*255+.5) for v in color)
            data = base64.b64encode(png(pixels)).decode()
            (ROOT/'fixtures'/f'turbulence_{kind}_{name}.reference.svg').write_text(
                '<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">'
                f'<image width="128" height="128" href="data:image/png;base64,{data}"/></svg>')
    samples = []
    for seed in [0,-4,13.75,42]:
        for octaves in [1,3,9]:
            for fractal in [False,True]:
                for x,y in [(0,0),(15,23),(47,39),(63,63),(126,126)]:
                    samples.append(dict(seed=seed, octaves=octaves, fractal=fractal, x=x, y=y,
                        rgba=rgba(seed,(x+1,y+1),(.07,.04),octaves,fractal)))
    for scale in [.5, 2, 4]:
        for x,y in [(16,24),(47,39),(63,63)]:
            px, py = int(x*scale), int(y*scale)
            samples.append(dict(seed=42, octaves=3, fractal=True, scale=scale, x=px, y=py,
                rgba=rgba(42,((px+.5)/scale+.5,(py+.5)/scale+.5),(.07,.04),3,True)))
    (ROOT/'turbulence_samples.json').write_text(json.dumps(samples,indent=2)+'\n')

if __name__ == '__main__':
    main()
