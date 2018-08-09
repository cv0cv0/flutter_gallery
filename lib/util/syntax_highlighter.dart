import 'package:flutter/material.dart';
import 'package:string_scanner/string_scanner.dart';

class SyntaxHighlighterStyle {
  SyntaxHighlighterStyle({
    this.baseStyle,
    this.numberStyle,
    this.commentStyle,
    this.keywordStyle,
    this.stringStyle,
    this.punctuationStyle,
    this.classStyle,
    this.constantStyle,
  });

  static SyntaxHighlighterStyle lightThemeStyle() => SyntaxHighlighterStyle(
        baseStyle: const TextStyle(color: Color(0xFF000000)),
        numberStyle: const TextStyle(color: Color(0xFF1565C0)),
        commentStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        keywordStyle: const TextStyle(color: Color(0xFF9C27B0)),
        stringStyle: const TextStyle(color: Color(0xFF43A047)),
        punctuationStyle: const TextStyle(color: Color(0xFF000000)),
        classStyle: const TextStyle(color: Color(0xFF512DA8)),
        constantStyle: const TextStyle(color: Color(0xFF795548)),
      );

  static SyntaxHighlighterStyle dartThemeStyle() => SyntaxHighlighterStyle(
        baseStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        numberStyle: const TextStyle(color: Color(0xFF1565C0)),
        commentStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        keywordStyle: const TextStyle(color: Color(0xFF80CBC4)),
        stringStyle: const TextStyle(color: Color(0xFF009688)),
        punctuationStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        classStyle: const TextStyle(color: Color(0xFF009688)),
        constantStyle: const TextStyle(color: Color(0xFF795548)),
      );

  final TextStyle baseStyle;
  final TextStyle numberStyle;
  final TextStyle commentStyle;
  final TextStyle keywordStyle;
  final TextStyle stringStyle;
  final TextStyle punctuationStyle;
  final TextStyle classStyle;
  final TextStyle constantStyle;
}

class SyntaxHighlighter {
  SyntaxHighlighter(this._style) {
    _spans = [];
  }

  static const _keywords = <String>[
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'external',
    'extends',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'if',
    'implements',
    'import',
    'in',
    'is',
    'library',
    'new',
    'null',
    'operator',
    'part',
    'rethrow',
    'return',
    'set',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  ];

  static const _builtInTypes = <String>[
    'int',
    'double',
    'num',
    'bool',
  ];

  String _src;
  StringScanner _scanner;
  List<_HighlightSpan> _spans;
  SyntaxHighlighterStyle _style;

  TextSpan format(String src) {
    _src = src;
    _scanner = StringScanner(src);

    if (_generateSpans()) {
      final formattedText = <TextSpan>[];
      int currentPosition = 0;

      for (var span in _spans) {
        if (currentPosition != span.start) {
          formattedText
              .add(TextSpan(text: src.substring(currentPosition, span.start)));
        }
        formattedText.add(TextSpan(
            style: span.textStyle(_style), text: span.textForSpan(src)));
        currentPosition = span.end;
      }

      if (currentPosition != src.length) {
        formattedText
            .add(TextSpan(text: src.substring(currentPosition, src.length)));
      }

      return TextSpan(style: _style.baseStyle, children: formattedText);
    } else {
      return TextSpan(style: _style.baseStyle, text: src);
    }
  }

  bool _generateSpans() {
    int lastLoopPosition = _scanner.position;

    while (!_scanner.isDone) {
      // Skip White space
      _scanner.scan(RegExp(r'\s+'));

      // Block comments
      if (_scanner.scan(RegExp(r'/\*(.|\n)*\*/'))) {
        _spans.add(_HighlightSpan(
          _HighlightType.comment,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Line comments
      if (_scanner.scan('//')) {
        final startComment = _scanner.lastMatch.start;

        bool eof = false;
        int endComment;
        if (_scanner.scan(RegExp(r'.*\n'))) {
          endComment = _scanner.lastMatch.end - 1;
        } else {
          eof = true;
          endComment = _src.length;
        }

        _spans.add(_HighlightSpan(
          _HighlightType.comment,
          startComment,
          endComment,
        ));

        if (eof) break;

        continue;
      }

      // Raw r"String"
      if (_scanner.scan(RegExp(r'r".*"'))) {
        _spans.add(_HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Raw r'String'
      if (_scanner.scan(new RegExp(r"r'.*'"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Multiline """String"""
      if (_scanner.scan(RegExp(r'"""(?:[^"\\]|\\(.|\n))*"""'))) {
        _spans.add(_HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Multiline '''String'''
      if (_scanner.scan(new RegExp(r"'''(?:[^'\\]|\\(.|\n))*'''"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // "String"
      if (_scanner.scan(new RegExp(r'"(?:[^"\\]|\\.)*"'))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // 'String'
      if (_scanner.scan(new RegExp(r"'(?:[^'\\]|\\.)*'"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Double
      if (_scanner.scan(new RegExp(r'\d+\.\d+'))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.number,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Integer
      if (_scanner.scan(new RegExp(r'\d+'))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.number,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Punctuation
      if (_scanner.scan(new RegExp(r'[\[\]{}().!=<>&\|\?\+\-\*/%\^~;:,]'))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.punctuation,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Meta data
      if (_scanner.scan(new RegExp(r'@\w+'))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.keyword,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end,
        ));
        continue;
      }

      // Words
      if (_scanner.scan(RegExp(r'\w+'))) {
        _HighlightType type;

        String word = _scanner.lastMatch[0];
        if (word.startsWith('_')) word = word.substring(1);

        if (_keywords.contains(word)) {
          type = _HighlightType.keyword;
        } else if (_builtInTypes.contains(word)) {
          type = _HighlightType.keyword;
        } else if (_firstLetterIsUpperCase(word)) {
          type = _HighlightType.klass;
        } else if (word.length >= 2 &&
            word.startsWith('k') &&
            _firstLetterIsUpperCase(word.substring(1))) {
          type = _HighlightType.constant;
        }

        if (type != null) {
          _spans.add(_HighlightSpan(
            type,
            _scanner.lastMatch.start,
            _scanner.lastMatch.end,
          ));
        }
      }

      if (lastLoopPosition == _scanner.position) return false;
      lastLoopPosition = _scanner.position;
    }

    _simplify();
    return true;
  }

  void _simplify() {
    for (var i = _spans.length - 2; i >= 0; i--) {
      if (_spans[i].type == _spans[i + 1].type &&
          _spans[i].end == _spans[i + 1].start) {
        _spans[i] = _HighlightSpan(
          _spans[i].type,
          _spans[i].start,
          _spans[i + 1].end,
        );
        _spans.removeAt(i + 1);
      }
    }
  }

  bool _firstLetterIsUpperCase(String str) {
    if (str.isNotEmpty) {
      final first = str.substring(0, 1);
      return first == first.toUpperCase();
    }
    return false;
  }
}

class _HighlightSpan {
  _HighlightSpan(this.type, this.start, this.end);

  final _HighlightType type;
  final int start;
  final int end;

  String textForSpan(String src) => src.substring(start, end);

  TextStyle textStyle(SyntaxHighlighterStyle style) {
    switch (type) {
      case _HighlightType.number:
        return style.numberStyle;
      case _HighlightType.comment:
        return style.commentStyle;
      case _HighlightType.keyword:
        return style.keywordStyle;
      case _HighlightType.string:
        return style.stringStyle;
      case _HighlightType.punctuation:
        return style.punctuationStyle;
      case _HighlightType.klass:
        return style.classStyle;
      case _HighlightType.constant:
        return style.constantStyle;
      default:
        return style.baseStyle;
    }
  }
}

enum _HighlightType {
  number,
  comment,
  keyword,
  string,
  punctuation,
  klass,
  constant,
}
