part of 'element.dart';

class TextElem extends Inline {
  TextElem(String text) : super(ElemType.text, text: text);
}

enum EmphasisType {
  bold(ElemType.bold),
  italic(ElemType.italic);

  final ElemType type;

  const EmphasisType(this.type);
}

class Emphasis extends Inline {
  final EmphasisType emphasisType;

  Emphasis(this.emphasisType, String text) : super(emphasisType.type, text: text);
}

enum Lang {
  none('');

  final String type;

  const Lang(this.type);

  static Lang of(String type) {
    return Lang.values.firstWhere(
      (element) => element.type == type,
      orElse: () => Lang.none,
    );
  }
}

class Code extends Inline {
  final Lang lang;

  Code(this.lang, {String? text}) : super(ElemType.code, text: text ?? '');

  static Code from(Element element) {
    return Code(Lang.of(element.attributes['class'] ?? ''), text: element.children?.first.textContent);
  }
}
