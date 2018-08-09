import 'dart:async';

import 'package:flutter/services.dart';

const String _kStartTag = '// START ';
const String _kEndTag = '// END';

Map<String, String> _code;

Future<String> getCode(String tag, AssetBundle bundle) async {
  if (_code == null) await _parseCode(bundle);
  return _code[tag];
}

Future<Null> _parseCode(AssetBundle bundle) async {
  final String code = await bundle.loadString('lib/util/example_code.dart') ??
      '// lib/util/example_code.dart not found\n';
  final lines = code.split('\n');

  List<String> codeBlock;
  String codeTag;

  _code = {};
  for (var line in lines) {
      if (codeBlock==null) {
        if (line.startsWith(_kStartTag)) {
          codeBlock=[];
          codeTag=line.substring(_kStartTag.length).trim();
        }        
      } else {
        if (line.startsWith(_kEndTag)) {
          _code[codeTag]=codeBlock.join('\n');
          codeBlock=null;
          codeTag=null;
        } else {
          codeBlock.add(line.trimRight());
        }
      }
  }
}
