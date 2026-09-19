// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

/// A shader asset or runtime program could not be loaded or instantiated.
class FilterShaderException implements Exception {
  /// Preserves the failing asset and the original engine diagnostic.
  const FilterShaderException(this.asset, this.cause);

  /// Package asset that failed.
  final String asset;

  /// Original asset-loading, compilation, or runtime error.
  final Object cause;

  @override
  String toString() =>
      'Could not load or instantiate SVG filter shader "$asset". '
      'SVG filters use Canvas Paint.shader, supported by both Skia and Impeller; '
      'they do not require the Impeller-only ImageFilter.shader API. '
      'Check that the vector_graphics shaders are included in the application '
      'bundle, rebuild the application, and verify runtime fragment-program '
      'support on the active renderer. Original error: $cause';
}

/// Shared immutable programs; each invocation owns its mutable shader instance.
class FilterShaders {
  FilterShaders._(this._programs);

  final Map<String, FragmentProgram> _programs;
  static final Map<String, Future<FragmentProgram>> _pending = <String, Future<FragmentProgram>>{};

  /// Package-local tests bundle their own assets without a package prefix.
  @visibleForTesting
  static String debugAssetPrefix = 'packages/vector_graphics/';

  /// Loads only requested programs, sharing concurrent loads by asset path.
  /// Failed entries are removed so corrected assets can be retried.
  static Future<FilterShaders> load([
    Iterable<String> names = const <String>['passthrough'],
  ]) async {
    final programs = <String, FragmentProgram>{};
    await Future.wait(<Future<void>>[
      for (final name in names.toSet())
        _load(name).then((FragmentProgram program) {
          programs[name] = program;
        }),
    ]);
    return FilterShaders._(programs);
  }

  static Future<FragmentProgram> _load(String name) {
    final String asset = _assetPath(name);
    return _pending.putIfAbsent(
      asset,
      () => FragmentProgram.fromAsset(asset).catchError((Object error, StackTrace stack) {
        _pending.remove(asset);
        Error.throwWithStackTrace(FilterShaderException(asset, error), stack);
      }),
    );
  }

  /// Programs needed by the operations in these filter definitions.
  static Set<String> requiredBy(Iterable<VectorFilter> filters) {
    final names = <String>{};
    for (final filter in filters) {
      for (final VectorFilter primitive in filter.children) {
        switch (primitive.name) {
          case 'feComposite':
            if (primitive.attributes['operator'] == 'arithmetic') {
              names.add('composite');
            }
          case 'feMorphology':
            final List<String> radius = (primitive.attributes['radius'] ?? '0').trim().split(
              RegExp(r'[\s,]+'),
            );
            if (radius.length == 2 &&
                ((double.tryParse(radius[0]) == 0) != (double.tryParse(radius[1]) == 0))) {
              names.add('morphology_axis');
            }
          case 'feComponentTransfer':
            if (primitive.children.any(
              (VectorFilter child) => (child.attributes['type'] ?? 'identity') != 'identity',
            )) {
              names.add('component_transfer');
            }
          case 'feConvolveMatrix':
            names.add('convolve_matrix');
        }
      }
    }
    return names;
  }

  static String _assetPath(String name) =>
      '${kDebugMode ? debugAssetPrefix : 'packages/vector_graphics/'}shaders/filter_$name.frag';

  /// Creates an invocation-local shader. The filter context owns its lifetime.
  FragmentShader create(String name) {
    final FragmentProgram? program = _programs[name];
    if (program == null) {
      throw StateError('Filter shader $name has not been loaded');
    }
    try {
      return program.fragmentShader();
    } catch (error, stack) {
      Error.throwWithStackTrace(FilterShaderException(_assetPath(name), error), stack);
    }
  }
}
