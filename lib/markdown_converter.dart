import 'package:markdown/markdown.dart';

import 'element/element.dart';

class MarkdownConverter {
  void convert(List<MarkdownElem> output, Node node, int depth) {
    if (node is! Element) {
      output.add(TextElem(node.textContent));
      return;
    }

    ElemType elemType = ElemType.of(node.tag);
    if (elemType.inline) {
      output.add(_convertToInline(node, depth));
    } else {
      _parseBlock(output, node, elemType, depth);
    }
  }

  Inline _convertToInline(Element element, int depth) {
    // case ElemType.heading:
    // return ;
    var childText = element.children?.first.textContent;
    switch (ElemType.of(element.tag)) {
      case ElemType.bold:
        return Emphasis(EmphasisType.bold, childText ?? element.textContent);
      case ElemType.italic:
        return Emphasis(EmphasisType.italic, childText ?? element.textContent);
      case ElemType.code:
        return Code.from(element);
      case ElemType.image:
        return ImageLink.from(element);
      case ElemType.link:
        return UrlLink.from(element);
      case ElemType.text:
      default:
        return TextElem(childText ?? '');
    }
  }

  void _parseBlock(List<MarkdownElem> output, Element element, ElemType type, int depth) {
    switch (type) {
      case ElemType.heading:
        output.add(_convertToHeading(element, depth));
        break;
      case ElemType.rule:
        output.add(Rule());
        break;
      case ElemType.preformatted:
        output.add(_convertToPreformatted(element, depth));
        break;
      case ElemType.paragraph:
        output.add(_convertToParagraph(element, depth));
        break;
      case ElemType.blockQuote:
        output.add(_convertToBackQuote(element, depth));
        break;
      case ElemType.orderList:
      case ElemType.unOrderList:
        output
            .addAll(_convertToList(element, depth, type == ElemType.orderList ? ListType.ordered : ListType.unOrdered));
        break;
      case ElemType.listLine:
      // Should not come here
      default:
        break;
    }
  }

  Heading _convertToHeading(Element element, int depth) {
    var heading = Heading(int.parse(element.tag.substring(1, 2)));
    var children = element.children;
    if (children == null) {
      heading.children.add(TextElem(element.textContent));
    } else {
      for (var child in children) {
        if (child is! Element) {
          heading.children.add(TextElem(child.textContent));
        } else if (ElemType.of(child.tag).inline) {
          heading.children.add(_convertToInline(child, depth));
        }
      }
    }
    return heading;
  }

  Preformatted _convertToPreformatted(Element element, int depth) {
    Node? child = element.children?.first;
    // For now it could be code only
    if (child != null && child is Element && ElemType.of(child.tag) == ElemType.code) {
      return Preformatted(Code.from(child), depth);
    } else {
      return Preformatted(Code(Lang.none, text: child?.textContent), depth);
    }
  }

  Paragraph _convertToParagraph(Element element, int depth) {
    Paragraph paragraph = Paragraph();
    var children = element.children;
    if (children != null) {
      for (var node in children) {
        if (node is! Element) {
          paragraph.children.add(TextElem(node.textContent));
        } else {
          paragraph.children.add(_convertToInline(node, depth));
        }
      }
    } else {
      paragraph.children.add(TextElem(''));
    }
    return paragraph;
  }

  void _breakDownBlocks(List<Block> output, Paragraph paragraph, Element element, int depth) {
    var children = element.children;
    if (children != null) {
      for (var node in children) {
        if (node is! Element) {
          paragraph.children.add(TextElem(node.textContent));
        } else {
          ElemType type = ElemType.of(node.tag);
          if (type.inline) {
            Inline outputElem = _convertToInline(node, depth);
            paragraph.children.add(outputElem);
          } else {
            _parseBlock(output, node, type, depth + 1);
            break; // Should have no more children after this
          }
        }
      }
    }
  }

  BlockQuote _convertToBackQuote(Element element, int depth) {
    var blockQuote = BlockQuote();
    var children = element.children;
    if (children != null) {
      Paragraph paragraph = Paragraph();
      blockQuote.children.add(paragraph);
      _breakDownBlocks(blockQuote.children, paragraph, element, depth);
    }
    return blockQuote;
  }

  void _breakDownList(List<Block> output, Element element, ListInfo listInfo, {int index = 0}) {
    if (element.children == null) return;

    int currentLineIndex = index;
    for (Node node in element.children!) {
      if (node is Element && ElemType.of(node.tag) == ElemType.listLine) {
        MarkdownListLine listLine = MarkdownListLine(listInfo, currentLineIndex);
        output.add(listLine);

        Paragraph paragraph = Paragraph();
        listLine.children.add(paragraph);
        _breakDownBlocks(output, paragraph, node, listInfo.depth);

        currentLineIndex += 1;
      }
    }
  }

  List<Block> _convertToList(Element element, int depth, ListType type) {
    List<Block> blocks = List.empty(growable: true);
    int start = int.parse(element.attributes['start'] ?? '0');
    _breakDownList(blocks, element, ListInfo(type, depth), index: start);
    return blocks;
  }
}
