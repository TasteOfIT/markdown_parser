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
    var paragraph = Paragraph();
    paragraph.children = [];
    var children = element.children;
    if (children != null) {
      for (var node in children) {
        if (node is Text) {
          paragraph.children.add(UnParsed(node.text));
        }
        if (node is Element) {
          _convertEmphasis(node, paragraph);
        }
      }
    }
    result = paragraph;
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

MarkDownList _convertList(
    Element element, int deep, MarkDownList list, ListType type,
    {num index = 0}) {
  ListType currentType = type;
  var currentDeepIndex = index;
  if (element.tag == "ol") currentType = ListType.ordered;
  if (element.tag == "ul") currentType = ListType.unOrdered;

  if (element.children != null || element.tag == "li") {
    for (Node node in element.children!) {
      if (node is Element) {
        if (node.tag == "li") {
          _convertList(node, deep, list, currentType, index: currentDeepIndex);
        } else {
          _convertList(node, deep + 1, list, type, index: 0);
        }
      }
      if (node is Text) {
        list.data.add(MarkDownListNode(currentType, deep, node.text, currentDeepIndex.toInt()));
      }
      currentDeepIndex += 1;
    }
  }
  return list;
}

void _convertEmphasis(Element node, Paragraph paragraph) {
  var childText = node.children?.first.textContent;
  switch (node.tag) {
    case "strong":
      paragraph.children.add(Emphasis(EmphasisType.bold, childText ?? ""));
      break;
    case "em":
      if (node.children?.first is Text) {
        paragraph.children.add(Emphasis(EmphasisType.italic, childText ?? ""));
      }
      break;
    case "code":
      if (node.children?.first is Text) {
        paragraph.children.add(Emphasis(EmphasisType.code, childText ?? ""));
      }
  }
}
