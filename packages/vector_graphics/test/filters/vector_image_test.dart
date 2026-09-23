// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_shaders.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/src/vector_image.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as compiler;

import 'helpers.dart';

Uint8List compiled(String svg) => compiler.encodeSvg(
  xml: svg,
  debugName: 'nested test',
  enableClippingOptimizer: false,
  enableMaskingOptimizer: false,
  enableOverdrawOptimizer: false,
);

ByteData wrapped(
  Uint8List bytes, {
  int copies = 1,
  bool draw = true,
  ui.Rect destination = const ui.Rect.fromLTWH(16, 24, 64, 32),
  Float64List? transform,
}) {
  const codec = VectorGraphicsCodec();
  final buffer = VectorGraphicsBuffer();
  codec.writeSize(buffer, 128, 128);
  for (var i = 0; i < copies; i++) {
    codec.writeImage(buffer, ImageFormatTypes.vector, bytes);
  }
  if (draw) {
    for (var i = 0; i < copies; i++) {
      codec.writeDrawImage(
        buffer,
        i,
        destination.left,
        destination.top,
        destination.width,
        destination.height,
        transform,
      );
    }
  }
  return buffer.done();
}

Future<PictureInfo> decoded(ByteData data) => decodeVectorGraphics(
  data,
  locale: null,
  textDirection: ui.TextDirection.ltr,
  clipViewbox: true,
  loader: const AssetBytesLoader('nested test'),
);

Future<ui.Image> rendered(ByteData data, {double scale = 1}) async {
  final PictureInfo info = await decoded(data);
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)..scale(scale);
  canvas.drawPicture(info.picture);
  info.picture.dispose();
  final ui.Picture picture = recorder.endRecording();
  try {
    return await picture.toImage((128 * scale).round(), (128 * scale).round());
  } finally {
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FilterShaders.debugAssetPrefix = '';
  final Uint8List red = compiled(
    '<svg width="16" height="8"><rect width="8" height="8" fill="red"/></svg>',
  );
  for (final scale in <double>[.5, 1, 2, 4]) {
    test('nested picture placement and retained lifetime at scale $scale', () async {
      final ui.Image image = await rendered(wrapped(red), scale: scale);
      final Uint8List data = await pixels(image);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final bool filled =
              x >= 16 * scale && x < 48 * scale && y >= 24 * scale && y < 56 * scale;
          final int p = (y * image.width + x) * 4;
          expect(data[p + 3], filled ? 255 : 0, reason: '$x,$y');
          if (filled) {
            expect(data.sublist(p, p + 3), <int>[255, 0, 0]);
          }
        }
      }
      image.dispose();
      expect(debugGetPendingDecodeTasks, isEmpty);
    });
  }
  for (var offset = 0; offset < 8; offset++) {
    test('nested asset in a ByteData view at offset $offset', () async {
      final ByteData data = wrapped(red);
      final bytes = Uint8List(data.lengthInBytes + offset + 3);
      bytes.setRange(
        offset,
        offset + data.lengthInBytes,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final ui.Image image = await rendered(bytes.buffer.asByteData(offset, data.lengthInBytes));
      final Uint8List dataPixels = await pixels(image);
      image.dispose();
      expect(dataPixels[(40 * 128 + 40) * 4 + 3], 255);
    });
  }
  test('thin vector geometry is not rasterized at the intrinsic size', () async {
    final Uint8List thin = compiled(
      '<svg width="16" height="16"><rect x="1.25" width=".125" height="16" fill="red"/></svg>',
    );
    final ui.Image image = await rendered(
      wrapped(thin, destination: const ui.Rect.fromLTWH(0, 0, 128, 128)),
      scale: 4,
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    for (var x = 0; x < 512; x++) {
      expect(data[(200 * 512 + x) * 4 + 3], x >= 40 && x < 44 ? 255 : 0);
    }
  });
  test('nested draw transform is applied once', () async {
    final transform = Float64List.fromList(<double>[
      .5,
      0,
      0,
      0,
      0,
      .5,
      0,
      0,
      0,
      0,
      1,
      0,
      32,
      16,
      0,
      1,
    ]);
    final ui.Image image = await rendered(
      wrapped(red, destination: const ui.Rect.fromLTWH(0, 0, 64, 64), transform: transform),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    for (final (int x, int y, int alpha) in <(int, int, int)>[
      (31, 20, 0),
      (33, 20, 255),
      (47, 40, 255),
      (49, 40, 0),
      (40, 49, 0),
    ]) {
      expect(data[(y * 128 + x) * 4 + 3], alpha);
    }
  });
  test('nested resources have independent image identifiers', () async {
    const png =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg==';
    final Uint8List asset = compiled(
      '<svg width="16" height="16"><image width="16" height="16" href="data:image/png;base64,$png"/></svg>',
    );
    final ui.Image image = await rendered(wrapped(asset));
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 4), <int>[0, 0, 255, 255]);
  });
  test('oversized nested raster fails before allocation and clears pending work', () async {
    const png =
        'iVBORw0KGgoAAAANSUhEUgAAIAEAAAABCAYAAACZiUteAAAAN0lEQVR4nO3DAQ0AAADCoPcvrUVgo9VUVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV1XaT0sWwdob9iAAAAABJRU5ErkJggg==';
    final Uint8List asset = compiled(
      '<svg width="16" height="16"><image width="16" height="16" href="data:image/png;base64,$png"/></svg>',
    );
    await expectLater(
      decoded(wrapped(asset)),
      throwsA(isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('8192'))),
    );
    expect(debugGetPendingDecodeTasks, isEmpty);
  });
  test('filters inside nested vector pictures execute before composition', () async {
    final ui.Image image = await rendered(
      wrapped(compiled(filterSvg('<feFlood flood-color="blue"/>'))),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 4), <int>[0, 0, 255, 255]);
  });
  for (final depth in <int>[1, 4, 16]) {
    test('nested vector depth $depth', () async {
      ByteData data = red.buffer.asByteData();
      for (var i = 0; i < depth; i++) {
        data = wrapped(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          destination: const ui.Rect.fromLTWH(0, 0, 128, 128),
        );
      }
      final ui.Image image = await rendered(data);
      final Uint8List pixelsData = await pixels(image);
      image.dispose();
      expect(pixelsData[(40 * 128 + 40) * 4 + 3], 255);
    });
  }
  test('depth limit rejects malicious nesting and clears pending work', () async {
    ByteData data = red.buffer.asByteData();
    for (var i = 0; i < 17; i++) {
      data = wrapped(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    await expectLater(
      decoded(data),
      throwsA(
        isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('depth limit')),
      ),
    );
    expect(debugGetPendingDecodeTasks, isEmpty);
  });
  for (final bytes in <Uint8List>[
    Uint8List(0),
    Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
  ]) {
    test('malformed nested binary ${bytes.length}', () async {
      await expectLater(decoded(wrapped(bytes)), throwsA(isA<VectorGraphicsDecodeException>()));
      expect(debugGetPendingDecodeTasks, isEmpty);
    });
  }
  test('resource count limit includes all sibling decodes', () async {
    await expectLater(
      decoded(wrapped(red, copies: 257)),
      throwsA(
        isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('256 images')),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(debugGetPendingDecodeTasks, isEmpty);
  });
  test('encoded resource bytes are checked before parsing', () async {
    await expectLater(
      decoded(wrapped(Uint8List(32 * 1024 * 1024 + 1))),
      throwsA(isA<Object>().having((Object e) => e.toString(), 'diagnostic', contains('32 MiB'))),
    );
    expect(debugGetPendingDecodeTasks, isEmpty);
  });
  test(
    'nested filters share a pixel budget with siblings and close all pictures on failure',
    () async {
      final pictures = <ui.Picture>[];
      final ui.PictureEventCallback? previous = ui.Picture.onCreate;
      ui.Picture.onCreate = (ui.Picture picture) {
        pictures.add(picture);
        previous?.call(picture);
      };
      try {
        final Uint8List asset = compiled(
          filterSvg('<feComposite operator="arithmetic" k2="1"/>').replaceAll('128', '512'),
        );
        await expectLater(
          decoded(wrapped(asset, copies: 33, destination: const ui.Rect.fromLTWH(0, 0, 512, 512))),
          throwsA(
            isA<Object>().having(
              (Object e) => e.toString(),
              'diagnostic',
              contains('pixel intermediate budget'),
            ),
          ),
        );
        expect(debugGetPendingDecodeTasks, isEmpty);
        expect(pictures, isNotEmpty);
        expect(pictures.every((ui.Picture picture) => picture.debugDisposed), isTrue);
      } finally {
        ui.Picture.onCreate = previous;
      }
    },
  );
  test('unused nested resource still finishes and is disposed', () async {
    final pictures = <ui.Picture>[];
    final ui.PictureEventCallback? previous = ui.Picture.onCreate;
    ui.Picture.onCreate = (ui.Picture picture) {
      pictures.add(picture);
      previous?.call(picture);
    };
    try {
      final PictureInfo info = await decoded(wrapped(red, draw: false));
      info.picture.dispose();
      expect(debugGetPendingDecodeTasks, isEmpty);
      expect(pictures.every((ui.Picture picture) => picture.debugDisposed), isTrue);
    } finally {
      ui.Picture.onCreate = previous;
    }
  });
  test('abort disposes a late nested picture', () async {
    final pictures = <ui.Picture>[];
    final ui.PictureEventCallback? previous = ui.Picture.onCreate;
    ui.Picture.onCreate = (ui.Picture picture) {
      pictures.add(picture);
      previous?.call(picture);
    };
    try {
      final listener = FlutterVectorGraphicsListener();
      listener.onImage(0, ImageFormatTypes.vector, compiled(filterSvg('<feOffset/>')));
      listener.abort();
      await listener.waitForImageDecode();
      expect(pictures.every((ui.Picture picture) => picture.debugDisposed), isTrue);
    } finally {
      ui.Picture.onCreate = previous;
    }
  });
  test('vector resource disposal is idempotent and guards use after disposal', () {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final ui.Picture picture = recorder.endRecording();
    final resource = VectorImage.vector(picture, const ui.Size(16, 16));
    resource.dispose();
    resource.dispose();
    expect(picture.debugDisposed, isTrue);
    final other = ui.PictureRecorder();
    final canvas = ui.Canvas(other);
    expect(() => resource.draw(canvas, const ui.Rect.fromLTWH(0, 0, 16, 16)), throwsStateError);
    other.endRecording().dispose();
  });
}
