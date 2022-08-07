import 'package:markdown/markdown.dart';
import 'package:markdown_parser/element/element.dart';

extension NodeExtensions on Node {
  MarkDownElement convertToMarkDownElement() {
    MarkDownElement? result;
    if (this is Element) {
      result = _convertElement(this as Element);
    } else {
      result = UnParsed(textContent);
    }
    return result ?? UnParsed("");
  }
}

extension ElementExtensions on Element {
  Text? getDeepestText() {
    var current = this;
    Text? text;
    while (text == null) {
      var children = current.children;
      if (children != null && children.length != 1) {
        break;
      } else {
        var child = current.children?.first;
        if (child is Element) {
          current = child;
        } else if (child is Text) {
          text = child;
        } else {
          break;
        }
      }
    }
    return text;
  }
}

final _headingPattern = RegExp("h[1-6]");

MarkDownElement? _convertElement(Element element) {
  MarkDownElement? result;
  //header
  if (_headingPattern.hasMatch(element.tag)) {
    result =
        Heading(int.parse(element.tag.substring(1, 2)), element.textContent);
  }

  //paragraph
  if (element.tag == 'p') {
    result = _convertParagraph(element);
  }

  //code block
  if (element.tag == 'pre') {
    result = CodeBlock(element.getDeepestText()?.textContent ?? "");
  }

  //List
  if (element.tag == 'ul') {
    result = _convertList(element, 0, MarkDownList(), ListType.unOrdered);
  }
  if (element.tag == 'ol') {
    result = _convertList(element, 0, MarkDownList(), ListType.ordered);
  }

  return result;
}

Paragraph _convertParagraph(Element element) {
  var paragraph = Paragraph();
  paragraph.children = [];
  var children = element.children;
  if (children != null) {
    for (var node in children) {
      if (node is Text) {
        paragraph.children.add(UnParsed(node.text));
      }
      if (node is Element) {
        var emphasis = _convertEmphasis(node);
        if (emphasis != null) {
          paragraph.children.add(emphasis);
        }
      }
    }
  }
  return paragraph;
}

MarkDownList _convertList(
    Element element, int deep, MarkDownList list, ListType type,
    {num index = 0}) {
  if (element.children == null) return list;
  ListType currentType = type;
  var currentDeepIndex = index;
  if (element.tag == "ol") currentType = ListType.ordered;
  if (element.tag == "ul") currentType = ListType.unOrdered;
  for (Node node in element.children!) {
    if (node is Element) {
      switch (node.tag) {
        case "ul":
        case "ol":
          _convertList(node, deep + 1, list, type, index: 0);
          break;
        case "li":
          if (node.children == null) {
            break;
          } else {
            Paragraph paragraph = Paragraph();
            paragraph.children = [];
            MarkDownListNode listNode =
                MarkDownListNode(currentType, deep, currentDeepIndex.toInt());
            listNode.childContent = paragraph;
            list.data.add(listNode);
            for (Node node in node.children!) {
              if (node is Text) {
                paragraph.children.add(UnParsed(node.text));
              }
              if (node is Element) {
                if (node.tag == "ul" || node.tag == "ol") {
                  _convertList(node, deep + 1, list, currentType, index: 0);
                } else {
                  paragraph.children.add(_convertEmphasis(node)!);
                }
              }
            }
          }
          break;
      }
    }
    currentDeepIndex += 1;
  }
  return list;
}

Emphasis? _convertEmphasis(Element node) {
  Emphasis? result;
  var childText = node.children?.first.textContent;
  switch (node.tag) {
    case "strong":
      result = Emphasis(EmphasisType.bold, childText ?? "");
      break;
    case "em":
      if (node.children?.first is Text) {
        result = Emphasis(EmphasisType.italic, childText ?? "");
      }
      break;
    case "code":
      if (node.children?.first is Text) {
        result = Emphasis(EmphasisType.code, childText ?? "");
      }
  }
  return result;
}
