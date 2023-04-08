abstract class MarkdownElement {}

class Paragraphs extends MarkdownElement {
  late List<MarkdownElement> children;
}

class Heading extends MarkdownElement {
  int level;
  String text;

  Heading(this.level, this.text);
}

enum EmphasisType { bold, italic, boldAndItalic, code }

class Emphasis extends MarkdownElement {
  EmphasisType type;
  String text;

  Emphasis(this.type, this.text);
}

class Paragraph extends MarkdownElement {
  late List<MarkdownElement> children;
}

class MarkdownImage extends MarkdownElement {
  String address;
  String alt;

  MarkdownImage(this.address, this.alt);
}

class CodeBlock extends MarkdownElement {
  String text;

  CodeBlock(this.text);
}

class MarkdownList extends MarkdownElement {
  late List<MarkdownListNode> data = [];
}

class MarkdownListNode {
  ListType type;
  int deep;
  int index;
  MarkdownElement? childContent;

  MarkdownListNode(this.type, this.deep, this.index, {this.childContent});
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

class MarkdownText extends MarkdownElement {
  String text = "";

  MarkdownText(this.text);
}
