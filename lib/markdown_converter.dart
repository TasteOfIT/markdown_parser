import 'package:markdown/markdown.dart';

import 'element/element.dart';

class MarkdownConverter {
  void convert(List<MarkdownElement> output, Node node, int depth) {
    if (node is! Element) {
      output.add(Plain(node.textContent));
      return;
    }

    ElementType elementType = ElementType.of(node.tag);
    if (elementType.isParent) {
      _breakDown(output, node, elementType, depth);
    } else {
      output.add(_convertToElement(node, depth));
    }
  }

  MarkdownElement _convertToElement(Element element, int depth) {
    var childText = element.children?.first.textContent;
    switch (ElementType.of(element.tag)) {
      case ElementType.heading:
        return Heading(int.parse(element.tag.substring(1, 2)), element.textContent);
      case ElementType.bold:
        return Emphasis(EmphasisType.bold, childText ?? element.textContent);
      case ElementType.italic:
        return Emphasis(EmphasisType.italic, childText ?? element.textContent);
      case ElementType.code:
        return CodeBlock(childText ?? '', Lang.of(element.attributes['class'] ?? ''));
      case ElementType.image:
        return ImageLink(element.attributes['src'] ?? '', element.attributes['alt'] ?? '');
      case ElementType.link:
        return UrlLink(element.attributes['href'] ?? '', childText ?? '');
      case ElementType.plain:
      default:
        return Plain(childText ?? '');
    }
  }

  Preformatted _convertToPreformatted(Element element, int depth) {
    Node? child = element.children?.first;
    if (child != null && child is Element && ElementType.of(child.tag) == ElementType.code) {
      CodeBlock? content = _convertToElement(child, depth) as CodeBlock?;
      return Preformatted(content ?? CodeBlock(child.textContent, Lang.none), depth);
    } else {
      return Preformatted(CodeBlock(child?.textContent ?? '', Lang.none), depth);
    }
  }

  void _breakDown(List<MarkdownElement> output, Element element, ElementType type, int depth) {
    switch (type) {
      case ElementType.preformatted:
        output.add(_convertToPreformatted(element, depth));
        break;
      case ElementType.paragraph:
        Paragraph paragraph = Paragraph();
        output.add(paragraph);
        _breakDownParagraph(output, paragraph, element, depth);
        break;
      case ElementType.blockQuote:
        Paragraph paragraph = Paragraph(isBackQuote: true);
        output.add(paragraph);
        _breakDownParagraph(output, paragraph, element, depth);
        break;
      case ElementType.orderList:
        _breakDownList(output, element, depth, ListType.ordered);
        break;
      case ElementType.unOrderList:
        _breakDownList(output, element, depth, ListType.unOrdered);
        break;
      case ElementType.listLine:
        // Should not come here
        break;
      default:
        break;
    }
  }

  void _breakDownParagraph(List<MarkdownElement> output, Paragraph paragraph, Element element, int depth) {
    var children = element.children;
    if (children != null) {
      for (var node in children) {
        if (node is! Element) {
          paragraph.children.add(Plain(node.textContent));
        } else {
          ElementType type = ElementType.of(node.tag);
          if (type.isParent) {
            _breakDown(output, node, type, depth + 1);
            break; // Should have no more children after this
          } else {
            MarkdownElement outputElem = _convertToElement(node, depth);
            if (outputElem.type.inline) {
              paragraph.children.add(outputElem);
            } else {
              output.add(outputElem);
              break; // Should have no more children after this
            }
          }
        }
      }
    }
  }

  void _breakDownList(List<MarkdownElement> output, Element element, int depth, ListType type, {int index = 0}) {
    if (element.children == null) return;

    ListInfo listInfo = ListInfo(type, depth);
    int currentLineIndex = index;
    for (Node node in element.children!) {
      if (node is Element && ElementType.of(node.tag) == ElementType.listLine) {
        MarkdownListLine listLine = MarkdownListLine(listInfo, currentLineIndex);
        output.add(listLine);

        Paragraph paragraph = Paragraph();
        listLine.children.add(paragraph);
        _breakDownParagraph(output, paragraph, node, depth);

        currentLineIndex += 1;
      }
    }
  }
}
