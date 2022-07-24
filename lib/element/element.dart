abstract class MarkDownElement {}

class Paragraphs extends MarkDownElement {
  late List<MarkDownElement> children;
}

class Heading extends MarkDownElement {
  int level;
  String text;

  Heading(this.level, this.text);
}

enum EmphasisType { bold, italic, boldAndItalic, code }

class Emphasis extends MarkDownElement {
  EmphasisType type;
  String text;

  Emphasis(this.type, this.text);
}

class Paragraph extends MarkDownElement {
  late List<MarkDownElement> children;
}

class CodeBlock extends MarkDownElement {
  String text;

  CodeBlock(this.text);
}

class MarkDownList extends MarkDownElement {
  late List<MarkDownListNode> data = [];
}

class MarkDownListNode {
  ListType type;
  int deep;
  String content;
  int index;

  MarkDownListNode(this.type, this.deep, this.content, this.index);
}

enum ListType { ordered, unOrdered }

class UnParsed extends MarkDownElement {
  String text = "";

  UnParsed(this.text);
}
