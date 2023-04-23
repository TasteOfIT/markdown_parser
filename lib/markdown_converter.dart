import 'package:markdown/markdown.dart';

import 'element/element.dart';

class MarkdownConverter {
  void convert(List<MarkdownElem> output, Node node, int depth) {
    if (node is! Element) {
      output.add(TextElem(node.textContent));
    } else if (ElemType.of(node.tag).inline) {
      _parseInline(output, node.children);
    } else {
      _parseBlock(output, node, ElemType.of(node.tag), depth);
    }
  }

  void _parseInline(List<MarkdownElem> inlines, List<Node>? nodes) {
    if (nodes == null || nodes.isEmpty) {
      return;
    }
    for (var node in nodes) {
      if (node is! Element) {
        inlines.add(TextElem(node.textContent));
      } else if (ElemType.of(node.tag) == ElemType.paragraph) {
        inlines.add(_convertToParagraph(node));
      } else if (ElemType.of(node.tag).inline) {
        var elem = _convertToInline(node);
        if (elem != null) {
          var children = node.children;
          if (children != null) {
            _parseInline(elem.spanChildren, children);
          }
          inlines.add(elem);
        }
      }
    }
  }

  Inline? _convertToInline(Element element) {
    var content = element.textContent;
    switch (ElemType.of(element.tag)) {
      case ElemType.bold:
        return Emphasis(EmphasisType.bold, content);
      case ElemType.italic:
        return Emphasis(EmphasisType.italic, content);
      case ElemType.code:
        return Code.from(element);
      case ElemType.image:
        return ImageLink.from(element);
      case ElemType.link:
        return UrlLink.from(element);
      case ElemType.text:
      default:
        return null;
    }
  }

  void _parseBlock(List<MarkdownElem> output, Element element, ElemType type, int depth) {
    switch (type) {
      case ElemType.heading:
        output.add(_convertToHeading(element));
        break;
      case ElemType.rule:
        output.add(Rule());
        break;
      case ElemType.preformatted:
        output.add(_convertToPreformatted(element));
        break;
      case ElemType.paragraph:
        output.add(_convertToParagraph(element));
        break;
      case ElemType.blockQuote:
        output.add(_convertToBlockQuote(element, depth));
        break;
      case ElemType.orderList:
      case ElemType.unOrderList:
        output.addAll(
          _convertToList(element, depth, type == ElemType.orderList ? ListType.ordered : ListType.unOrdered),
        );
        break;
      case ElemType.listLine:
      // Should not come here
      default:
        break;
    }
  }

  Heading _convertToHeading(Element element) {
    var heading = Heading(int.parse(element.tag.substring(1, 2)));
    _parseInline(heading.children, element.children);
    return heading;
  }

  Preformatted _convertToPreformatted(Element element) {
    Node? child = element.children?.first;
    // For now it could be code only
    if (child != null && child is Element && ElemType.of(child.tag) == ElemType.code) {
      return Preformatted(Code.from(child));
    } else {
      return Preformatted(Code(Lang.none, text: child?.textContent));
    }
  }

  Paragraph _convertToParagraph(Element node) {
    Paragraph paragraph = Paragraph();
    _parseInline(paragraph.children, node.children);
    return paragraph;
  }

  void _breakDownBlocks(List<Block> output, List<MarkdownElem> parent, Element element, int depth) {
    var children = element.children;
    if (children != null) {
      var currentParagraph = Paragraph();
      for (var node in children) {
        if (node is! Element) {
          currentParagraph.children.add(TextElem(node.textContent));
        } else if (ElemType.of(node.tag).inline) {
          var elem = _convertToInline(node);
          if (elem != null) {
            currentParagraph.children.add(elem);
            var inlineChildren = node.children;
            if (inlineChildren != null) {
              _parseInline(elem.spanChildren, inlineChildren);
            }
          }
        } else {
          if (currentParagraph.children.isNotEmpty) {
            parent.add(currentParagraph);
            currentParagraph = Paragraph();
          }
          _parseBlock(output, node, ElemType.of(node.tag), depth);
        }
      }
      if (currentParagraph.children.isNotEmpty) {
        parent.add(currentParagraph);
      }
    }
  }

  BlockQuote _convertToBlockQuote(Element element, int depth) {
    var blockQuote = BlockQuote();
    _breakDownBlocks(blockQuote.children, blockQuote.children, element, depth);
    return blockQuote;
  }

  void _breakDownList(List<Block> output, Element element, ListInfo listInfo, {int index = 0}) {
    if (element.children == null) return;

    int currentLineIndex = index;
    for (Node node in element.children!) {
      if (node is Element && ElemType.of(node.tag) == ElemType.listLine) {
        MarkdownListLine listLine = MarkdownListLine(listInfo, currentLineIndex);
        output.add(listLine);

        _breakDownBlocks(output, listLine.children, node, listInfo.depth + 1);
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
