# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Generate analytic SVG references without invoking the implementation under test."""
import math
import re
from pathlib import Path
P = Path(__file__).resolve().parents[1] / 'test/filters'

def linear(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

def srgb(v):
    return 12.92 * v if v <= 0.0031308 else 1.055 * v ** (1 / 2.4) - 0.055

def source(x, y, lin):
    if 24 <= x < 64 and 24 <= y < 88:
        r, g, b, a = (192, 96, 32, 255)
    elif 64 <= x < 104 and 40 <= y < 104:
        r, g, b, a = (32, 128, 192, 128)
    else:
        return (0.0, 0.0, 0.0, 0.0)
    alpha = a / 255
    return tuple((linear(round(c * alpha) / 255 / alpha) * alpha if lin else round(c * alpha) / 255 for c in (r, g, b))) + (alpha,)
kernels = {'emboss': ([-2, -1, 0, -1, 1, 1, 0, 1, 2], 0.2), 'edge': ([-1, -1, -1, -1, 8, -1, -1, -1, -1], 0.5), 'bias': ([1], 0.25), 'negative_bias': ([1], -0.25), 'alpha_create': ([0], 0.5)}
for name, (kernel, bias) in kernels.items():
    for color in ['sRGB', 'linearRGB']:
        lin = color == 'linearRGB'
        n = int(math.sqrt(len(kernel)))
        div = sum(kernel) or 1
        pixels = []
        for y in range(128):
            row = []
            for x in range(128):
                sums = [0.0] * 4
                for ky in range(n):
                    for kx in range(n):
                        v = source(min(127, max(0, x + kx - n // 2)), min(127, max(0, y + ky - n // 2)), lin)
                        weight = kernel[len(kernel) - 1 - (ky * n + kx)] / div
                        for ch in range(4):
                            sums[ch] += v[ch] * weight
                a = max(0, min(1, sums[3] + bias))
                rgb = [max(0, min(a, c + bias * a)) / a if a else 0 for c in sums[:3]]
                if lin:
                    rgb = list(map(srgb, rgb))
                row.append(tuple((round(c * 255, 5) for c in rgb)) + (round(a, 7),))
            pixels.append(row)
        rects = []
        for y, row in enumerate(pixels):
            x = 0
            while x < 128:
                v = row[x]
                end = x + 1
                while end < 128 and row[end] == v:
                    end += 1
                if v[3] > 0:
                    rects.append(f'<rect x="{x}" y="{y}" width="{end - x}" height="1" fill="rgb({v[0]},{v[1]},{v[2]})" fill-opacity="{v[3]}"/>')
                x = end
        (P / 'fixtures' / f'convolve_{name}_{color}.reference.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" shape-rendering="crispEdges">' + ''.join(rects) + '</svg>')
for name in ['mismatch', 'missing']:
    (P / 'fixtures' / f'convolve_{name}.reference.svg').write_text(re.sub('<feConvolveMatrix[^>]*/>', '<feOffset/>', (P / 'fixtures' / f'convolve_{name}.svg').read_text()))
for name, w, h in [('units_4', 32, 32), ('units_4_8', 32, 16), ('object_units', 32, 16)]:
    p = P / 'fixtures' / f'convolve_{name}.svg'
    s = p.read_text()
    s = re.sub(' kernelUnitLength="[^"]*"', '', s)
    s = s.replace('width="128" height="128"', 'width="%s" height="%s" viewBox="0 0 128 128" preserveAspectRatio="none" data-reference-raster-width="%s" data-reference-raster-height="%s"' % (w, h, w, h), 1)
    p.with_suffix('.reference.svg').write_text(s)
