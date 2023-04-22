part of 'element.dart';

class Heading extends Block<Inline> {
  final int level;

  Heading(this.level) : super(ElemType.heading);
}

class Rule extends Block<Inline> {
  Rule() : super(ElemType.rule, text: '');
}

class Paragraph extends Block<Inline> {
  Paragraph() : super(ElemType.paragraph);
}

class Preformatted extends Block<Inline> {
  final Code content;
  final int depth;

  Preformatted(this.content, this.depth) : super(ElemType.preformatted);
}

class BlockQuote extends Block<Block> {
  BlockQuote() : super(ElemType.blockQuote);
}

enum ListType {
  ordered,
  unOrdered;
}

class ListInfo {
  final ListType listType;
  final int depth;

  ListInfo(this.listType, this.depth);
}

class MarkdownListLine extends Block<Block> {
  final ListInfo listInfo;
  final int index;

  MarkdownListLine(this.listInfo, this.index) : super(ElemType.listLine);
}
