library markdown_parser;

import 'dart:convert';

import 'package:markdown/markdown.dart';

import 'element/element.dart';
import 'markdown_converter.dart';

export 'element/element.dart';

class MarkdownParser {
  Document document = Document(
      extensionSet: ExtensionSet.gitHubFlavored,
      blockSyntaxes: ExtensionSet.gitHubFlavored.blockSyntaxes,
      inlineSyntaxes: ExtensionSet.gitHubFlavored.inlineSyntaxes);

  List<MarkdownElem> parse(String content) {
    var elements = <MarkdownElem>[];
    var nodes = document.parseLines(const LineSplitter().convert(content));

    var markDownConverter = MarkdownConverter();
    for (Node node in nodes) {
      markDownConverter.convert(elements, node, 0);
    }

    return elements;
  }
}
