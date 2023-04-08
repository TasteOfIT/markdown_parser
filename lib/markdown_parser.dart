library markdown_parser;

import 'dart:convert';

import 'package:markdown/markdown.dart';

import 'element/element.dart';
import 'markdown_converter.dart';

class MarkdownParser {
  Document document = Document(
      extensionSet: ExtensionSet.gitHubFlavored,
      blockSyntaxes: ExtensionSet.gitHubFlavored.blockSyntaxes,
      inlineSyntaxes: ExtensionSet.gitHubFlavored.inlineSyntaxes);

  List<MarkdownElement> parse(String content) {
    var elements = <MarkdownElement>[];
    var nodes = document.parseLines(const LineSplitter().convert(content));

    var markDownConverter = MarkdownConverter();
    for (Node node in nodes) {
      elements.add(markDownConverter.convert(node, 0) ?? MarkdownText(node.textContent));
    }

    return elements;
  }
}
