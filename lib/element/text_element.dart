part of 'element.dart';

class Plain extends MarkdownElement {
  String text = "";

  Plain(this.text, {ElementType type = ElementType.plain}) : super(type);
}

class Heading extends Plain {
  int level;

  Heading(this.level, String text) : super(text, type: ElementType.heading);
}

enum EmphasisType {
  bold(ElementType.bold),
  italic(ElementType.italic);

  final ElementType type;

  const EmphasisType(this.type);
}

class Emphasis extends Plain {
  EmphasisType emphasisType;

  Emphasis(this.emphasisType, super.text) : super(type: emphasisType.type);
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

class CodeBlock extends Plain {
  Lang lang;

  CodeBlock(String text, this.lang) : super(text, type: ElementType.code);
}
