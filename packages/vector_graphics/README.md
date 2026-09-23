# vector_graphics

A vector graphics rendering runtime for Flutter. This package is intended for
use with output from the `package:vector_graphics_compiler` and encoded via
a tightly coupled version of `package:vector_graphics_codec`.

## Commemoration

This package was originally authored by
[Dan Field](https://github.com/dnfield) and has been forked here
from [dnfield/vector_graphics](https://github.com/dnfield/vector_graphics).
Dan was a member of the Flutter team at Google from 2018 until his death
in 2024. Dan’s impact and contributions to Flutter were immeasurable, and we
honor his memory by continuing to publish and maintain this package.

## Filter resolution and performance

`VectorGraphic.filterRasterScale` overrides samples per SVG unit for SVG filter
textures. Only filters that actually create raster intermediates follow layout, `BoxFit` and device pixel ratio in power-of-two
buckets. After a resize the previous picture remains visible until replacement
decoding completes. Vector-only filters such as `feOffset` keep one picture across layout and DPR changes.
The first filtered decode waits for layout so a large SVG displayed as an icon
does not allocate textures at its intrinsic size. Embedded SVG filters use the
scale of their `feImage` or image placement, including the outer filter resolution.
Ancestor paint transforms require an explicit override.
Low-level `vg.loadPicture`/`decodeVectorGraphics` callers must choose the resolution
for their eventual Canvas scale; the decoder does not know that scale.

Shader outputs are rasterized once at that resolution, and repeated sampling of
an identical input rectangle/grid reuses its texture. This bounds repeated shader
work during picture playback but trades vector scaling for a chosen resolution.
Branching filter graphs also materialize intermediates when repeated picture
references exceed 128 leaf replays; linear vector chains remain scalable.
Memory and computation limits do not guarantee a frame-time budget. First-render
cost must be measured on the target device; static, expensive graphics can also
use the final-image raster rendering strategy.

Encoded image dimensions are checked before decoding on native backends. Flutter
Web exposes those dimensions only after decoding, so its pixel limit is checked
then; encoded byte and nesting limits still apply before decoding.

Visual reference provenance is recorded in `test/filters/reference/sources.json`.
Run `example/integration_test/filter_backend_test.dart` on a native host to check
float parameters and collect first-render/readback, process RSS and frame timings.
Debug-mode measurements are diagnostic and should be repeated in profile mode
for release decisions. Process RSS is not a measurement of GPU texture memory.

Unsupported filter primitives or inputs fail the decode with a diagnostic naming
the operation. Use the widget's `errorBuilder` for an application fallback; effects
are never silently discarded. Independent unfiltered subtrees still use compiler
optimizations; filter sources retain their original geometry.

Run `python3 tool/filter_web_tests.py` with Flutter and Chrome on PATH to execute
the filter suites, including visual references, in Chrome/CanvasKit. The script
builds a temporary asset host, keeping test assets out of the published library.
Failed visual comparisons save PNGs under the host's `build/filter_failures`.
Blur references use explicit approximation bounds plus an independent scalar
Gaussian oracle. Combined lighting and thresholded-noise fixtures allow small,
documented differences from backend kernel and intermediate-pixel rounding;
these are not pixel-identical guarantees across renderers.

This unreleased series changes the codec, compiler, runtime and flutter_svg
together. Source checkouts must resolve all four packages from the same revision.
Before publishing, they need coordinated release versions and dependency lower
bounds that include the new APIs; existing pub versions cannot
be mixed with this series.
