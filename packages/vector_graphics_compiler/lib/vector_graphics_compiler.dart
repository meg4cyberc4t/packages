// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:xml/xml.dart';

import 'src/geometry/image.dart';
import 'src/geometry/matrix.dart';
import 'src/geometry/path.dart';
import 'src/geometry/pattern.dart';
import 'src/geometry/vertices.dart';
import 'src/paint.dart';
import 'src/svg/color_mapper.dart';
import 'src/svg/parser.dart';
import 'src/svg/theme.dart';
import 'src/vector_instructions.dart';

export 'src/_initialize_path_ops_io.dart'
    if (dart.library.js_interop) 'src/_initialize_path_ops_web.dart';
export 'src/_initialize_tessellator_io.dart'
    if (dart.library.js_interop) 'src/_initialize_tessellator_web.dart';
export 'src/geometry/basic_types.dart';
export 'src/geometry/matrix.dart';
export 'src/geometry/path.dart';
export 'src/geometry/vertices.dart';
export 'src/paint.dart';
export 'src/svg/color_mapper.dart';
export 'src/svg/path_ops.dart' show initializeLibPathOps;
export 'src/svg/resolver.dart';
export 'src/svg/tessellator.dart' show initializeLibTesselator;
export 'src/svg/theme.dart';
export 'src/vector_instructions.dart';

/// Parses an SVG string into a [VectorInstructions] object, with all optional
/// optimizers disabled.
VectorInstructions parseWithoutOptimizers(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
  ColorMapper? colorMapper,
}) {
  return parse(
    xml,
    key: key,
    warningsAsErrors: warningsAsErrors,
    theme: theme,
    enableClippingOptimizer: false,
    enableMaskingOptimizer: false,
    enableOverdrawOptimizer: false,
    colorMapper: colorMapper,
  );
}

/// Parses an SVG string into a [VectorInstructions] object.
VectorInstructions parse(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
  bool enableMaskingOptimizer = true,
  bool enableClippingOptimizer = true,
  bool enableOverdrawOptimizer = true,
  ColorMapper? colorMapper,
}) {
  final parser = SvgParser(xml, theme, key, warningsAsErrors, colorMapper);
  parser.enableMaskingOptimizer = enableMaskingOptimizer;
  parser.enableClippingOptimizer = enableClippingOptimizer;
  parser.enableOverdrawOptimizer = enableOverdrawOptimizer;
  return parser.parse();
}

Float64List? _encodeMatrix(AffineMatrix? matrix) {
  if (matrix == null || matrix == AffineMatrix.identity) {
    return null;
  }
  return matrix.toMatrix4();
}

void _encodeShader(
  Gradient? shader,
  Map<Gradient, int> shaderIds,
  VectorGraphicsCodec codec,
  VectorGraphicsBuffer buffer,
) {
  if (shader == null) {
    return;
  }
  int shaderId;
  if (shader is LinearGradient) {
    shaderId = codec.writeLinearGradient(
      buffer,
      fromX: shader.from.x,
      fromY: shader.from.y,
      toX: shader.to.x,
      toY: shader.to.y,
      colors: Int32List.fromList(<int>[for (final Color color in shader.colors!) color.value]),
      offsets: Float32List.fromList(shader.offsets!),
      tileMode: shader.tileMode!.index,
    );
  } else if (shader is RadialGradient) {
    shaderId = codec.writeRadialGradient(
      buffer,
      centerX: shader.center.x,
      centerY: shader.center.y,
      radius: shader.radius,
      focalX: shader.focalPoint?.x,
      focalY: shader.focalPoint?.y,
      colors: Int32List.fromList(<int>[for (final Color color in shader.colors!) color.value]),
      offsets: Float32List.fromList(shader.offsets!),
      tileMode: shader.tileMode!.index,
      transform: _encodeMatrix(shader.transform),
    );
  } else {
    assert(false);
    throw StateError('illegal shader type: $shader');
  }
  shaderIds[shader] = shaderId;
}

/// String input, String filename
/// Encodes SVG [xml] into the vector_graphics binary format.
///
/// [imageSources] supplies bytes for external feImage references by their href.
/// Embedded data URIs and local fragment references are resolved automatically.
/// External resources are never fetched during synchronous compilation.
Uint8List encodeSvg({
  required String xml,
  required String debugName,
  SvgTheme theme = const SvgTheme(),
  bool enableMaskingOptimizer = true,
  bool enableClippingOptimizer = true,
  bool enableOverdrawOptimizer = true,
  bool warningsAsErrors = false,
  bool useHalfPrecisionControlPoints = false,
  ColorMapper? colorMapper,
  Map<String, Uint8List> imageSources = const <String, Uint8List>{},
}) => _SvgImageEncoder(
  debugName: debugName,
  theme: theme,
  enableMaskingOptimizer: enableMaskingOptimizer,
  enableClippingOptimizer: enableClippingOptimizer,
  enableOverdrawOptimizer: enableOverdrawOptimizer,
  warningsAsErrors: warningsAsErrors,
  useHalfPrecisionControlPoints: useHalfPrecisionControlPoints,
  colorMapper: colorMapper,
  imageSources: imageSources,
).encode(xml);

// The runtime has no XML parser. Compile referenced SVGs into independent binary
// image resources while preserving their native pictures at playback time.
class _SvgImageEncoder {
  _SvgImageEncoder({
    required this.debugName,
    required this.theme,
    required this.enableMaskingOptimizer,
    required this.enableClippingOptimizer,
    required this.enableOverdrawOptimizer,
    required this.warningsAsErrors,
    required this.useHalfPrecisionControlPoints,
    required this.colorMapper,
    required this.imageSources,
  });

  final String debugName;
  final SvgTheme theme;
  final bool enableMaskingOptimizer;
  final bool enableClippingOptimizer;
  final bool enableOverdrawOptimizer;
  final bool warningsAsErrors;
  final bool useHalfPrecisionControlPoints;
  final ColorMapper? colorMapper;
  final Map<String, Uint8List> imageSources;
  final Map<(String, String), (ImageData, bool)?> _cache = <(String, String), (ImageData, bool)?>{};
  final Set<(String, String)> _active = <(String, String)>{};
  int _bytes = 0;

  Uint8List encode(String xml, {String? referenceSource}) {
    final String document = referenceSource ?? xml;
    final VectorInstructions instructions = parse(
      xml,
      key: debugName,
      theme: theme,
      enableMaskingOptimizer: enableMaskingOptimizer,
      enableClippingOptimizer: enableClippingOptimizer,
      enableOverdrawOptimizer: enableOverdrawOptimizer,
      warningsAsErrors: warningsAsErrors,
      colorMapper: colorMapper,
    );
    final images = <ImageData>[];
    final ids = <(String, String), int>{};
    VectorFilter prepare(VectorFilter filter) {
      final attributes = Map<String, String>.of(filter.attributes);
      if (filter.name == 'feImage') {
        attributes.remove('vector-image-id');
        attributes.remove('vector-image-fragment');
        final String? href = attributes.remove('href');
        if (href != null && href.isNotEmpty) {
          final (String, String) key = (document, href);
          final (ImageData, bool)? image = _image(document, href);
          if (image != null) {
            final int id = ids.putIfAbsent(key, () {
              final int id = instructions.images.length + images.length;
              images.add(image.$1);
              return id;
            });
            attributes['vector-image-id'] = id.toString();
            attributes['vector-image-fragment'] = image.$2.toString();
          }
        }
      }
      return VectorFilter(filter.name, attributes, filter.children.map(prepare).toList());
    }

    final filters = <VectorFilter, VectorFilter>{};
    for (final DrawCommand command in instructions.commands) {
      if (command.type == DrawCommandType.beginFilter) {
        filters.putIfAbsent(command.filter!, () => prepare(command.filter!));
      }
    }
    return _encodeInstructions(
      instructions,
      useHalfPrecisionControlPoints,
      filterImages: images,
      filters: filters,
    );
  }

  (ImageData, bool)? _image(String document, String href) {
    final key = (document, href);
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    // A cyclic reference is an invalid image.
    if (_active.contains(key)) {
      return null;
    }
    if (_active.length >= 8 || _cache.length >= 256) {
      throw StateError('SVG filter image compilation exceeds 8 levels or 256 resources');
    }
    _active.add(key);
    try {
      var normalized = href;
      final int base64Start = normalized.indexOf(';base64,');
      if (normalized.startsWith('data:') && base64Start >= 0) {
        normalized =
            normalized.substring(0, base64Start + 8) +
            Uri.decodeComponent(
              normalized.substring(base64Start + 8),
            ).replaceAll(RegExp(r'\s+'), '');
      }
      final Uri uri = Uri.parse(normalized);
      final String fragment = uri.fragment;
      String? svg;
      Uint8List? data;
      if (href.startsWith('#')) {
        svg = document;
      } else {
        final location = uri.removeFragment().toString();
        if (uri.scheme == 'data') {
          data = UriData.parse(location).contentAsBytes();
        } else {
          data = imageSources[href] ?? imageSources[location];
        }
        if (data == null) {
          return _cache[key] = null;
        }
        _bytes += data.length;
        if (_bytes > 32 * 1024 * 1024) {
          throw StateError('SVG filter images exceed 32 MiB');
        }
        // XML resources begin with '<' after a possible BOM and whitespace.
        final String probe = utf8.decode(data.take(256).toList(), allowMalformed: true).trimLeft();
        if (probe.startsWith('<')) {
          svg = utf8.decode(data);
        }
      }
      if (svg != null) {
        if (XmlDocument.parse(svg).rootElement.name.local != 'svg') {
          return _cache[key] = null;
        }
        if (fragment.isNotEmpty) {
          final String? source = _fragment(svg, fragment);
          if (source == null) {
            return _cache[key] = null;
          }
          data = encode(source, referenceSource: svg);
        } else {
          data = encode(svg);
        }
        _bytes += data.length;
        if (_bytes > 32 * 1024 * 1024) {
          throw StateError('SVG filter images exceed 32 MiB');
        }
        return _cache[key] = (ImageData(data, ImageFormatTypes.vector), fragment.isNotEmpty);
      }
      return _cache[key] = (ImageData(data!, ImageFormatTypes.filterRaster), false);
    } on FormatException {
      return _cache[key] = null;
    } on UnsupportedError {
      return _cache[key] = null;
    } on ArgumentError {
      return _cache[key] = null;
    } on XmlException {
      return _cache[key] = null;
    } finally {
      _active.remove(key);
    }
  }

  String? _fragment(String source, String id) {
    final XmlElement root = XmlDocument.parse(source).rootElement;
    final XmlElement? target = <XmlElement>[
      root,
      ...root.descendants.whereType<XmlElement>(),
    ].where((XmlElement e) => e.getAttribute('id') == id).firstOrNull;
    if (target == null) {
      return null;
    }
    // Referenced graphics retain computed inherited paint/text properties from
    // their original ancestry, but do not inherit ancestor transforms or opacity.
    final properties = <String, String>{};
    for (final element in <XmlElement>[
      ...target.ancestors.whereType<XmlElement>().toList().reversed,
      target,
    ]) {
      final attributes = <String, String>{
        for (final XmlAttribute a in element.attributes) a.name.local: a.value,
      };
      for (final String declaration in (attributes['style'] ?? '').split(';')) {
        final int colon = declaration.indexOf(':');
        if (colon > 0) {
          attributes[declaration.substring(0, colon).trim()] = declaration
              .substring(colon + 1)
              .trim();
        }
      }
      for (final MapEntry<String, String> entry in attributes.entries) {
        if (SvgAttributes.heritableProperties.contains(entry.key) &&
            entry.value != 'inherit' &&
            entry.value != 'unset') {
          properties[entry.key] = entry.value;
        }
      }
    }
    for (final MapEntry<String, String> entry in properties.entries) {
      target.setAttribute(entry.key, entry.value);
    }
    final String? targetStyle = target.getAttribute('style');
    if (targetStyle != null) {
      target.setAttribute(
        'style',
        targetStyle
            .split(';')
            .where(
              (String declaration) =>
                  !SvgAttributes.heritableProperties.contains(declaration.split(':').first.trim()),
            )
            .join(';'),
      );
    }
    final XmlElement wrapper = root.copy();
    wrapper.children.clear();
    const excluded = <String>{
      'id',
      'filter',
      'mask',
      'clip-path',
      'transform',
      'opacity',
      'x',
      'y',
      'viewBox',
    };
    wrapper.attributes.removeWhere((XmlAttribute a) => excluded.contains(a.name.local));
    final String? style = wrapper.getAttribute('style');
    if (style != null) {
      wrapper.setAttribute(
        'style',
        style
            .split(';')
            .where((String value) => !excluded.contains(value.split(':').first.trim()))
            .join(';'),
      );
    }
    final List<double>? viewBox = root
        .getAttribute('viewBox')
        ?.trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.parse)
        .toList();
    if (viewBox != null && viewBox.length == 4) {
      wrapper.setAttribute('width', viewBox[2].toString());
      wrapper.setAttribute('height', viewBox[3].toString());
    }
    wrapper.children.add(
      XmlElement(
        // XmlName is not const in supported xml 6.x releases.
        // ignore: prefer_const_constructors
        XmlName('defs'),
        <XmlAttribute>[],
        root.getAttribute('id') == id
            ? <XmlNode>[root.copy()]
            : root.children.map((XmlNode n) => n.copy()),
      ),
    );
    wrapper.children.add(
      // XmlName is not const in supported xml 6.x releases.
      // ignore: prefer_const_constructors
      XmlElement(XmlName('use'), <XmlAttribute>[XmlAttribute(XmlName('href'), '#$id')]),
    );
    return wrapper.toXmlString();
  }
}

Uint8List _encodeInstructions(
  VectorInstructions instructions,
  bool useHalfPrecisionControlPoints, {
  List<ImageData> filterImages = const <ImageData>[],
  Map<VectorFilter, VectorFilter> filters = const <VectorFilter, VectorFilter>{},
}) {
  const codec = VectorGraphicsCodec();
  final buffer = VectorGraphicsBuffer();

  codec.writeSize(buffer, instructions.width, instructions.height);

  final fillIds = <int, int>{};
  final strokeIds = <int, int>{};
  final shaderIds = <Gradient, int>{};

  for (final data in <ImageData>[...instructions.images, ...filterImages]) {
    codec.writeImage(buffer, data.format, data.data);
  }

  for (final Paint paint in instructions.paints) {
    _encodeShader(paint.fill?.shader, shaderIds, codec, buffer);
    _encodeShader(paint.stroke?.shader, shaderIds, codec, buffer);
  }

  var nextPaintId = 0;
  for (final Paint paint in instructions.paints) {
    final Fill? fill = paint.fill;
    final Stroke? stroke = paint.stroke;

    if (fill != null) {
      final int? shaderId = shaderIds[fill.shader];
      final int fillId = codec.writeFill(buffer, fill.color.value, paint.blendMode.index, shaderId);
      fillIds[nextPaintId] = fillId;
    }
    if (stroke != null) {
      final int? shaderId = shaderIds[stroke.shader];
      final int strokeId = codec.writeStroke(
        buffer,
        stroke.color.value,
        stroke.cap?.index ?? 0,
        stroke.join?.index ?? 0,
        paint.blendMode.index,
        stroke.miterLimit ?? 4,
        stroke.width ?? 1,
        shaderId,
      );
      strokeIds[nextPaintId] = strokeId;
    }
    nextPaintId += 1;
  }

  final pathIds = <int, int>{};
  var nextPathId = 0;
  for (final Path path in instructions.paths) {
    final controlPointTypes = <int>[];
    final controlPoints = <double>[];

    for (final PathCommand command in path.commands) {
      switch (command.type) {
        case PathCommandType.move:
          final move = command as MoveToCommand;
          controlPointTypes.add(ControlPointTypes.moveTo);
          controlPoints.addAll(<double>[move.x, move.y]);
        case PathCommandType.line:
          final line = command as LineToCommand;
          controlPointTypes.add(ControlPointTypes.lineTo);
          controlPoints.addAll(<double>[line.x, line.y]);
        case PathCommandType.cubic:
          final cubic = command as CubicToCommand;
          controlPointTypes.add(ControlPointTypes.cubicTo);
          controlPoints.addAll(<double>[
            cubic.x1,
            cubic.y1,
            cubic.x2,
            cubic.y2,
            cubic.x3,
            cubic.y3,
          ]);
        case PathCommandType.close:
          controlPointTypes.add(ControlPointTypes.close);
      }
    }
    final int id = codec.writePath(
      buffer,
      Uint8List.fromList(controlPointTypes),
      Float32List.fromList(controlPoints),
      path.fillType.index,
      half: useHalfPrecisionControlPoints,
    );
    pathIds[nextPathId] = id;
    nextPathId += 1;
  }

  for (final TextPosition position in instructions.textPositions) {
    codec.writeTextPosition(
      buffer,
      position.x,
      position.y,
      position.dx,
      position.dy,
      position.reset,
      position.transform?.toMatrix4(),
    );
  }

  for (final TextConfig textConfig in instructions.text) {
    codec.writeTextConfig(
      buffer: buffer,
      text: textConfig.text,
      fontFamily: textConfig.fontFamily,
      xAnchorMultiplier: textConfig.xAnchorMultiplier,
      fontWeight: textConfig.fontWeight.index,
      fontSize: textConfig.fontSize,
      decoration: textConfig.decoration.mask,
      decorationStyle: textConfig.decorationStyle.index,
      decorationColor: textConfig.decorationColor.value,
    );
  }

  for (final DrawCommand command in instructions.commands) {
    switch (command.type) {
      case DrawCommandType.pathGeometry:
        codec.writePathGeometry(buffer, pathIds[command.objectId]!);
      case DrawCommandType.beginFilter:
        codec.writeBeginFilter(
          buffer,
          filters[command.filter!] ?? command.filter!,
          command.filterTransform!.toMatrix4(),
          command.filterWidth!,
          command.filterHeight!,
        );
      case DrawCommandType.endFilter:
        codec.writeEndFilter(buffer);
      case DrawCommandType.path:
        if (fillIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            fillIds[command.paintId]!,
            command.patternId,
          );
        }
        if (strokeIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            strokeIds[command.paintId]!,
            command.patternId,
          );
        }
      case DrawCommandType.vertices:
        final IndexedVertices vertices = instructions.vertices[command.objectId!];
        final int fillId = fillIds[command.paintId]!;
        codec.writeDrawVertices(buffer, vertices.vertices, vertices.indices, fillId);
      case DrawCommandType.saveLayer:
        codec.writeSaveLayer(buffer, fillIds[command.paintId]!);
      case DrawCommandType.restore:
        codec.writeRestoreLayer(buffer);
      case DrawCommandType.clip:
        codec.writeClipPath(buffer, pathIds[command.objectId]!);
      case DrawCommandType.mask:
        codec.writeMask(buffer);

      case DrawCommandType.pattern:
        final PatternData patternData = instructions.patternData[command.patternDataId!];
        codec.writePattern(
          buffer,
          patternData.x,
          patternData.y,
          patternData.width,
          patternData.height,
          patternData.transform.toMatrix4(),
        );

      case DrawCommandType.textPosition:
        codec.writeUpdateTextPosition(buffer, command.objectId!);

      case DrawCommandType.text:
        if (command.paintId == null) {
          codec.writeTextGeometry(buffer, command.objectId!);
        } else {
          codec.writeDrawText(
            buffer,
            command.objectId!,
            fillIds[command.paintId],
            strokeIds[command.paintId],
            command.patternId,
          );
        }

      case DrawCommandType.image:
        final DrawImageData drawImageData = instructions.drawImages[command.objectId!];
        codec.writeDrawImage(
          buffer,
          drawImageData.id,
          drawImageData.rect.left,
          drawImageData.rect.top,
          drawImageData.rect.width,
          drawImageData.rect.height,
          drawImageData.transform?.toMatrix4(),
        );
    }
  }
  return buffer.done().buffer.asUint8List();
}
