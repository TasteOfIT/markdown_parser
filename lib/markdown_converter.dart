import 'package:markdown/markdown.dart';

import 'element/element.dart';
import 'extensions.dart';

class MarkDownConverter {
  static final _headingPattern = RegExp("h[1-6]");

  MarkDownElement? convert(Node node, int deep) {
    MarkDownElement? result;
    if (node is Text) {
      result = MarkdownText(node.textContent);
    }
    if (node is Element) {
      var childText = node.children?.first.textContent;

      if (_headingPattern.hasMatch(node.tag)) {
        result = Heading(int.parse(node.tag.substring(1, 2)), node.textContent);
      }
      switch (node.tag) {
        case "p":
          result = _convertParagraph(node, deep);
          break;
        case "pre":
          result = CodeBlock(node.getDeepestText()?.textContent ?? node.textContent);
          break;
        case "ul":
        case "ol":
          result = _convertList(node, deep, MarkDownList(), ListType.getType(node.tag));
          break;
        case "strong":
          result = Emphasis(EmphasisType.bold, childText ?? node.textContent);
          break;
        case "em":
          result = Emphasis(EmphasisType.italic, childText ?? node.textContent);
          break;
        case "code":
          result = Emphasis(EmphasisType.code, childText ?? node.textContent);
          break;
        case "img":
          result = MarkDownImage(
              node.attributes["src"] ?? "", node.attributes["alt"] ?? "");
          break;
      }
    }
    return result;
  }

  Paragraph _convertParagraph(Element element, int deep) {
    var paragraph = Paragraph();
    paragraph.children = [];
    var children = element.children;
    if (children != null) {
      for (var node in children) {
        paragraph.children.add(convert(node, deep + 1) ?? MarkdownText(""));
      }
    }
    return paragraph;
  }

  MarkDownList _convertList(Element element, int deep, MarkDownList list, ListType type, {num index = 0}) {
    if (element.children == null) return list;
    ListType currentType = type;
    var currentDeepIndex = index;
    for (Node node in element.children!) {
      if (node is Element) {
        switch (node.tag) {
          case "ul":
          case "ol":
            _convertList(node, deep + 1, list, type, index: 0);
            break;
          case "li":
            if (node.children != null) {
              Paragraph paragraph = Paragraph();
              paragraph.children = [];
              MarkDownListNode listNode = MarkDownListNode(currentType, deep, currentDeepIndex.toInt());
              listNode.childContent = paragraph;
              list.data.add(listNode);
              for (Node node in node.children!) {
                if (node is Text) {
                  paragraph.children.add(MarkdownText(node.text));
                }
                if (node is Element) {
                  if (node.tag == "ul" || node.tag == "ol") {
                    _convertList(node, deep + 1, list, ListType.getType(node.tag), index: 0);
                  } else {
                    paragraph.children.add(convert(node, deep + 1)!);
                  }
                }
              }
              break;
            }
        }
      }
      currentDeepIndex += 1;
    }
    return list;
  }
}
