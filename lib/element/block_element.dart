part of 'element.dart';

class Rule extends Block<Inline> {
  Rule() : super(ElemType.rule, text: '');
}

class Paragraph extends Block<Inline> {
  Paragraph({ElemType? type}) : super(type ?? ElemType.paragraph);
}

class Heading extends Paragraph {
  final int level;

  Heading(this.level) : super(type: ElemType.heading);
}

class Preformatted extends Block<Inline> {
  final Code content;

  Preformatted(this.content) : super(ElemType.preformatted);
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
