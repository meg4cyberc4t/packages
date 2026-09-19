// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

int lighting(
  String attributes, {
  String parent = '',
  SvgTheme theme = const SvgTheme(),
  ColorMapper? mapper,
}) {
  final VectorInstructions result = parseWithoutOptimizers(
    '<svg width="32" height="32"><defs><filter id="f" $parent><feDiffuseLighting id="lamp" $attributes><feDistantLight/></feDiffuseLighting></filter></defs><rect width="32" height="32" filter="url(#f)"/></svg>',
    theme: theme,
    colorMapper: mapper,
  );
  return int.parse(
    result.commands.first.filter!.children.single.attributes['lighting-color-argb']!,
  );
}

void main() {
  for (final MapEntry<String, int> entry in <String, int>{
    '': 0xffffffff,
    'lighting-color="red"': 0xffff0000,
    'lighting-color="#4080c0"': 0xff4080c0,
    'lighting-color="rgba(64,128,192,.5)"': 0x804080c0,
    'lighting-color="red" style="lighting-color: blue"': 0xff0000ff,
    'lighting-color="initial"': 0xffffffff,
  }.entries) {
    test('lighting color ${entry.key}', () => expect(lighting(entry.key), entry.value));
  }
  test(
    'lighting color is not inherited implicitly',
    () => expect(lighting('', parent: 'lighting-color="red"'), 0xffffffff),
  );
  test(
    'explicit inheritance uses ancestor lighting color',
    () => expect(lighting('lighting-color="inherit"', parent: 'lighting-color="red"'), 0xffff0000),
  );
  test(
    'currentColor inherits normal color property',
    () => expect(lighting('lighting-color="currentColor"', parent: 'color="#123456"'), 0xff123456),
  );
  test(
    'currentColor can use the theme',
    () => expect(
      lighting(
        'lighting-color="currentColor"',
        theme: const SvgTheme(currentColor: Color(0xff654321)),
      ),
      0xff654321,
    ),
  );
  test('ColorMapper receives lighting property and original element ID', () {
    final mapper = LightMapper();
    expect(lighting('lighting-color="blue"', mapper: mapper), 0xff123456);
    expect(mapper.call, ('lamp', 'feDiffuseLighting', 'lighting-color', const Color(0xff0000ff)));
  });
}

class LightMapper extends ColorMapper {
  (String?, String, String, Color)? call;
  @override
  Color substitute(String? id, String element, String attribute, Color color) {
    if (attribute == 'lighting-color') {
      call = (id, element, attribute, color);
      return const Color(0xff123456);
    }
    return color;
  }
}
