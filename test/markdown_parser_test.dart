import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_parser/markdown_parser.dart';

void main() {
  var parser = MarkdownParser();

  test('given text `plain`, when parse,then the first element is TextElem', () {
    String text = "plain";

    var elements = parser.parse(text);
    expect((elements.first as Paragraph).children.first.text, "plain");
  });

  test('given text `## header`,when parse,then the first element is Heading', () {
    String text = "## header";

    var elements = parser.parse(text);

    var isHeading = elements.first is Heading;
    expect(isHeading, true);
    expect((elements.first as Heading).level, 2);
    expect((elements.first as Heading).children.first.text, "header");
  });

  test('given text `## **bold** header`,when parse,then the first child element is bold', () {
    String text = "## **bold** header";

    var elements = parser.parse(text);

    var isHeading = elements.first is Heading;
    expect(isHeading, true);
    expect((elements.first as Heading).level, 2);
    expect((elements.first as Heading).children.first.type, ElemType.bold);
    expect((elements.first as Heading).children.first.text, "bold");
  });

  test("given text `**text**`,when parse, then the first element is Paragraph and its first child is bold", () {
    String text = "**text**";

    List<MarkdownElem> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isEmphasis = firstChild is Emphasis;
    expect(isEmphasis, true);
    expect((firstChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(firstChild.text, 'text');
  });

  test("given text `*text*`,when parse, then the first element is Paragraph and its first child is italic", () {
    String text = "*text*";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isEmphasis = firstChild is Emphasis;
    expect(isEmphasis, true);
    expect((firstChild as Emphasis).emphasisType, EmphasisType.italic);
    expect(firstChild.text, 'text');
  });

  test("given `**bold *text***`,when parse, then the first element is Paragraph and its first child is `bold`", () {
    String text = "**bold *text***";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    expect((firstChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(firstChild.text, 'bold text');
    var spanChildren = firstChild.spanChildren;
    expect((spanChildren.first as TextElem).text, 'bold ');
    expect((spanChildren[1] as Emphasis).emphasisType, EmphasisType.italic);
  });

  test("given text ``text``,when parse, then the first element is Paragraph and its first child is `code`", () {
    String text = "`text`";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isCodeBlock = firstChild is Code;
    expect(isCodeBlock, true);
    expect((firstChild as Code).lang.type, '');
    expect(firstChild.text, 'text');
  });

  test("given text ***italic* bold `code`**,when parse, then the inline code and emphasis are correct", () {
    String text = "***italic* bold `code`**";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    expect(firstChild is Emphasis, true);
    expect((firstChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(firstChild.text, 'italic bold code');
    var italicChild = firstChild.spanChildren.first;
    expect(italicChild is Emphasis, true);
    expect((italicChild as Emphasis).emphasisType, EmphasisType.italic);
    expect(italicChild.text, 'italic');
    var codeChild = firstChild.spanChildren[3];
    expect(codeChild is Code, true);
    expect((codeChild as Code).lang.type, '');
    expect(codeChild.text, 'code');
  });

  test("given text ***italic `code`* bold**,when parse, then the inline code and emphasis are correct", () {
    String text = "***italic `code`* bold**";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var boldChild = (elements.first as Paragraph).children.first;
    expect(boldChild is Emphasis, true);
    expect((boldChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(boldChild.text, 'italic code bold');
    var italicChild = boldChild.spanChildren.first;
    expect(italicChild is Emphasis, true);
    expect((italicChild as Emphasis).emphasisType, EmphasisType.italic);
    expect(italicChild.text, 'italic code');
    var codeChild = italicChild.spanChildren[1];
    expect(codeChild is Code, true);
    expect((codeChild as Code).lang.type, '');
    expect(codeChild.text, 'code');
  });

  test("given text with ``` and line space,when parse, then the first element is Preformatted", () {
    String text = "``` \ntext\n ```";

    var elements = parser.parse(text);

    var isPreformatted = elements.first is Preformatted;
    expect(isPreformatted, true);
    expect((elements.first as Preformatted).content.text, 'text\n');
  });

  test("given text > ***italic `code`* bold**,when parse, then the blockquote, inline code and emphasis are correct",
      () {
    String text = "> ***italic `code`* bold**";

    var elements = parser.parse(text);

    var blockQuote = elements.first is BlockQuote;
    expect(blockQuote, true);
    var boldChild = ((elements.first as BlockQuote).children.first as Paragraph).children.first;
    expect(boldChild is Emphasis, true);
    expect((boldChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(boldChild.text, 'italic code bold');
    var italicChild = boldChild.spanChildren.first;
    expect(italicChild is Emphasis, true);
    expect((italicChild as Emphasis).emphasisType, EmphasisType.italic);
    expect(italicChild.text, 'italic code');
    var codeChild = italicChild.spanChildren[1];
    expect(codeChild is Code, true);
    expect((codeChild as Code).lang.type, '');
    expect(codeChild.text, 'code');
  });

  test("given unordered list, when parse, then the first line is MarkdownListItem and the content is correct", () {
    String text = "- u1\n - u2\n - u3";
    var elements = parser.parse(text);
    expect(3, elements.length);
    expect(elements.first is MarkdownListLine, true);
    var firstLine = elements.first as MarkdownListLine;
    expect(0, firstLine.listInfo.depth);
    expect(ListType.unOrdered, firstLine.listInfo.listType);
    expect(0, firstLine.index);
    MarkdownElem content = (firstLine.children.first).children.first;
    expect("u1", (content as TextElem).text);
  });

  test("given ordered list, when parse, then the first line is MarkdownListItem and the content is correct", () {
    String text = "1. one\n 2. two\n 3. three";
    var elements = parser.parse(text);
    expect(3, elements.length);
    expect(elements.first is MarkdownListLine, true);
    expect(elements[1] is MarkdownListLine, true);
    expect(elements[2] is MarkdownListLine, true);
    var firstLine = elements.first as MarkdownListLine;
    expect(0, firstLine.listInfo.depth);
    expect(ListType.ordered, firstLine.listInfo.listType);
    expect(0, firstLine.index);
    MarkdownElem content = (firstLine.children.first).children.first;
    expect("one", (content as TextElem).text);
    var secondLine = elements[1] as MarkdownListLine;
    expect(1, secondLine.index);
    MarkdownElem content2 = (secondLine.children.first).children.first;
    expect("two", (content2 as TextElem).text);
  });

  test("given ordered list including unordered list, when parse, then the list are all correct", () {
    String text = "1. one\n"
        "2. two\n"
        "    - u1\n"
        "    - u2\n"
        "    - u3\n"
        "3. three\n"
        "    - u1\n"
        "    - u2\n"
        "    - u3\n";
    var elements = parser.parse(text);
    expect(9, elements.length);
    expect(elements.first is MarkdownListLine, true);
    expect(elements[1] is MarkdownListLine, true);
    expect(elements[2] is MarkdownListLine, true);
    expect(elements[3] is MarkdownListLine, true);
    var firstLine = elements.first as MarkdownListLine;
    expect(0, firstLine.listInfo.depth);
    expect(ListType.ordered, firstLine.listInfo.listType);
    expect(0, firstLine.index);
    MarkdownElem content = (firstLine.children.first).children.first;
    expect("one", (content as TextElem).text);
    var secondLine = elements[1] as MarkdownListLine;
    expect(1, secondLine.index);
    MarkdownElem content2 = (secondLine.children.first).children.first;
    expect("two", (content2 as TextElem).text);
    var firstInsideLine = elements[2] as MarkdownListLine;
    expect(1, firstInsideLine.listInfo.depth);
    expect(ListType.unOrdered, firstInsideLine.listInfo.listType);
    expect(0, firstInsideLine.index);
    MarkdownElem insideContent = (firstInsideLine.children.first).children.first;
    expect("u1", (insideContent as TextElem).text);
    var secondInsideLine = elements[3] as MarkdownListLine;
    expect(1, secondInsideLine.index);
    MarkdownElem insideContent2 = (secondInsideLine.children.first).children.first;
    expect("u2", (insideContent2 as TextElem).text);
  });

  test("given ordered list including inline, when parse, then the list and inline are correct", () {
    String text = "1. one ***bold** italic*\n2. two\n";
    var elements = parser.parse(text);
    expect(2, elements.length);
    expect(elements.first is MarkdownListLine, true);
    expect(elements[1] is MarkdownListLine, true);
    var firstLine = elements.first as MarkdownListLine;
    expect(0, firstLine.listInfo.depth);
    expect(ListType.ordered, firstLine.listInfo.listType);
    expect(0, firstLine.index);
    MarkdownElem plain = (firstLine.children.first).children.first;
    expect("one ", (plain as TextElem).text);
    MarkdownElem italic = (firstLine.children.first).children[1];
    expect("bold italic", (italic as Emphasis).text);
    expect(EmphasisType.italic, italic.emphasisType);
    MarkdownElem bold = italic.spanChildren.first;
    expect("bold", (bold as Emphasis).text);
    expect(EmphasisType.bold, bold.emphasisType);
    var secondLine = elements[1] as MarkdownListLine;
    expect(1, secondLine.index);
    MarkdownElem content2 = (secondLine.children.first).children.first;
    expect("two", (content2 as TextElem).text);
  });

  test("given markdown image,when parse, then the first element is Paragraph and its first child is `ImageLink`", () {
    String text = "![img](https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg)";

    List<MarkdownElem> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isMarkdownImage = firstChild is ImageLink;
    expect(isMarkdownImage, true);
    expect((firstChild as ImageLink).src, "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg");
    expect(firstChild.alt, 'img');
  });

  test("given markdown link, when parse, then the first element is Paragraph and its first child is `UrlLink`", () {
    String text = "[link](https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg)";

    List<MarkdownElem> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isLink = firstChild is UrlLink;
    expect(isLink, true);
    expect((firstChild as UrlLink).link, "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg");
    expect(firstChild.text, 'link');
  });
}
