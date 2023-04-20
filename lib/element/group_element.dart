part of 'element.dart';

abstract class Group<T extends MarkdownElement> extends MarkdownElement {
  List<T> children = List.empty(growable: true);

  Group(ElementType type) : super(type, '');
}

class Paragraph extends Group<MarkdownElement> {
  final bool isBackQuote;

  Paragraph({this.isBackQuote = false}) : super(ElementType.paragraph);
}

class Preformatted extends Group<Plain> {
  final CodeBlock content;
  final int depth;

  Preformatted(this.content, this.depth) : super(ElementType.preformatted);
}

class ListInfo {
  ListType listType;
  int depth;

  ListInfo(this.listType, this.depth);
}

class MarkdownListLine extends Group<Paragraph> {
  ListInfo listInfo;
  int index;

  MarkdownListLine(this.listInfo, this.index) : super(ElementType.listLine);
}

enum ListType {
  ordered,
  unOrdered;
}
