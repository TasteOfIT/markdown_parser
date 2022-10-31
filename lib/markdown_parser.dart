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

  List<MarkDownElement> parse(String content) {
    var elements = <MarkDownElement>[];
    var nodes = document.parseLines(const LineSplitter().convert(content));

    var markDownConverter = MarkDownConverter();
    for (Node node in nodes) {
      elements.add(
          markDownConverter.convert(node, 0) ?? MarkdownText(node.textContent));
    }

    return elements;
  }
}
