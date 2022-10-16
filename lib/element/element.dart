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
  int index;
  MarkDownElement? childContent;

  MarkDownListNode(this.type, this.deep, this.index, {this.childContent});
}

enum ListType {
  ordered,
  unOrdered;

  static ListType getType(String tag) {
    ListType result = ListType.ordered;
    switch (tag) {
      case "ol":
        result = ListType.ordered;
        break;
      case "ul":
        result = ListType.unOrdered;
        break;
    }
    return result;
  }
}

class UnParsed extends MarkDownElement {
  String text = "";

  UnParsed(this.text);
}
