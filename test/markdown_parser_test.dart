import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_parser/markdown_parser.dart';

void main() {
  var parser = MarkdownParser();

  test('given text `## header`,when parse,then the first element is Heading', () {
    String text = "## header";

    var elements = parser.parse(text);

    var isHeading = elements.first is Heading;
    expect(isHeading, true);
    expect((elements.first as Heading).level, 2);
    expect((elements.first as Heading).text, "header");
  });

  test("given text `**text**`,when parse, then the first element is Paragraph and its first child is `bold`", () {
    String text = "**text**";

    List<MarkdownElement> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isEmphasis = firstChild is Emphasis;
    expect(isEmphasis, true);
    expect((firstChild as Emphasis).emphasisType, EmphasisType.bold);
    expect(firstChild.text, 'text');
  });

  test("given text `*text*`,when parse, then the first element is Paragraph and its first child is `bold`", () {
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

  test("given text ``text``,when parse, then the first element is Paragraph and its first child is `code`", () {
    String text = "`text`";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isCodeBlock = firstChild is CodeBlock;
    expect(isCodeBlock, true);
    expect((firstChild as CodeBlock).lang.type, '');
    expect(firstChild.text, 'text');
  });

  test("given text with ``` and line space,when parse, then the first element is Preformatted", () {
    String text = "``` \ntext\n ```";

    var elements = parser.parse(text);

    var isPreformatted = elements.first is Preformatted;
    expect(isPreformatted, true);
    expect((elements.first as Preformatted).content.text, 'text\n');
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
    MarkdownElement content = (firstLine.children.first).children.first;
    expect("u1", (content as Plain).text);
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
    MarkdownElement content = (firstLine.children.first).children.first;
    expect("one", (content as Plain).text);
    var secondLine = elements[1] as MarkdownListLine;
    expect(1, secondLine.index);
    MarkdownElement content2 = (secondLine.children.first).children.first;
    expect("two", (content2 as Plain).text);
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
    MarkdownElement content = (firstLine.children.first).children.first;
    expect("one", (content as Plain).text);
    var secondLine = elements[1] as MarkdownListLine;
    expect(1, secondLine.index);
    MarkdownElement content2 = (secondLine.children.first).children.first;
    expect("two", (content2 as Plain).text);
    var firstInsideLine = elements[2] as MarkdownListLine;
    expect(1, firstInsideLine.listInfo.depth);
    expect(ListType.unOrdered, firstInsideLine.listInfo.listType);
    expect(0, firstInsideLine.index);
    MarkdownElement insideContent = (firstInsideLine.children.first).children.first;
    expect("u1", (insideContent as Plain).text);
    var secondInsideLine = elements[3] as MarkdownListLine;
    expect(1, secondInsideLine.index);
    MarkdownElement insideContent2 = (secondInsideLine.children.first).children.first;
    expect("u2", (insideContent2 as Plain).text);
  });

  test("given markdown image,when parse, then the first element is Paragraph and its first child is `ImageLink`", () {
    String text = "![img](https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg)";

    List<MarkdownElement> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isMarkdownImage = firstChild is ImageLink;
    expect(isMarkdownImage, true);
    expect((firstChild as ImageLink).address, "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg");
    expect(firstChild.alt, 'img');
  });

  test("given markdown link, when parse, then the first element is Paragraph and its first child is `UrlLink`", () {
    String text = "[link](https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg)";

    List<MarkdownElement> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isLink = firstChild is UrlLink;
    expect(isLink, true);
    expect((firstChild as UrlLink).address, "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg");
    expect(firstChild.text, 'link');
  });
}
