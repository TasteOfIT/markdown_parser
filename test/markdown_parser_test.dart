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
    expect((firstChild as Emphasis).type, EmphasisType.bold);
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
    expect((firstChild as Emphasis).type, EmphasisType.italic);
    expect(firstChild.text, 'text');
  });

  test("given text ``text``,when parse, then the first element is Paragraph and its first child is `code`", () {
    String text = "`text`";

    var elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isEmphasis = firstChild is Emphasis;
    expect(isEmphasis, true);
    expect((firstChild as Emphasis).type, EmphasisType.code);
    expect(firstChild.text, 'text');
  });

  test("given text with ``` and line space,when parse, then the first element is CodeBlock", () {
    String text = "``` \ntext\n ```";

    var elements = parser.parse(text);

    var isCodeBlock = elements.first is CodeBlock;
    expect(isCodeBlock, true);
    expect((elements.first as CodeBlock).text, 'text\n');
  });

  test("given unordered list, when parse, then the first element is MarkdownList and the content's length of it is 3",
      () {
    String text = "- u1\n - u2\n - u3";
    var elements = parser.parse(text);
    var isList = elements.first is MarkdownList;
    expect(isList, true);
    MarkdownElement element = ((elements.first as MarkdownList).data.first.childContent as Paragraph).children.first;
    expect("u1", (element as MarkdownText).text);
    expect(0, (elements.first as MarkdownList).data.first.deep);
    expect(ListType.unOrdered, (elements.first as MarkdownList).data.first.type);
  });

  test("given ordered list, when parse, then the first element is MarkdownList and the content's length of it is 3",
      () {
    String text = "1. one\n 2. two\n 3. three";
    var elements = parser.parse(text);
    var isList = elements.first is MarkdownList;
    expect(isList, true);
    expect(3, (elements.first as MarkdownList).data.length);
    MarkdownElement element = ((elements.first as MarkdownList).data.first.childContent as Paragraph).children.first;
    expect("one", (element as MarkdownText).text);
    expect(0, (elements.first as MarkdownList).data.first.deep);
    expect(ListType.ordered, (elements.first as MarkdownList).data.first.type);
    expect(0, (elements.first as MarkdownList).data.first.index);
  });

  test("given ordered list, when parse, then the first element is MarkdownList and the content's length of it is 3",
      () {
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
    var isList = elements.first is MarkdownList;
    expect(isList, true);
    expect(9, (elements.first as MarkdownList).data.length);
    MarkdownElement elementOne = ((elements.first as MarkdownList).data.first.childContent as Paragraph).children.first;
    expect("one", (elementOne as MarkdownText).text);
    expect(0, (elements.first as MarkdownList).data.first.deep);
    expect(ListType.ordered, (elements.first as MarkdownList).data.first.type);
    MarkdownElement elementU1 = ((elements.first as MarkdownList).data[2].childContent as Paragraph).children.first;
    expect("u1", (elementU1 as MarkdownText).text);
    MarkdownElement element = ((elements.first as MarkdownList).data[2].childContent as Paragraph).children.first;
    expect("u1", (element as MarkdownText).text);
    expect(1, (elements.first as MarkdownList).data[2].deep);
    expect(ListType.unOrdered, (elements.first as MarkdownList).data[2].type);
  });

  test("given markdown image,when parse, then the first element is Paragraph and its first child is `MarkdownImage`",
      () {
    String text = "![img](https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg)";

    List<MarkdownElement> elements = parser.parse(text);

    var isParagraph = elements.first is Paragraph;
    expect(isParagraph, true);
    var firstChild = (elements.first as Paragraph).children.first;
    var isMarkdownImage = firstChild is MarkdownImage;
    expect(isMarkdownImage, true);
    expect(
        (firstChild as MarkdownImage).address, "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg");
    expect(firstChild.alt, 'img');
  });
}
