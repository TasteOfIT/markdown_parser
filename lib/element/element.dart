import 'package:markdown/markdown.dart';

part 'block_element.dart';

part 'link_element.dart';

part 'text_element.dart';

abstract class MarkdownElem {
  final ElemType type;
  final String text;

  MarkdownElem(this.type, this.text);
}

abstract class Block<T extends MarkdownElem> extends MarkdownElem {
  final List<T> children = List.empty(growable: true);

  Block(ElemType type, {String text = ''}) : super(type, text);
}

abstract class Inline extends MarkdownElem {
  final List<Inline> spanChildren = List.empty(growable: true);

  Inline(ElemType type, {String text = ''}) : super(type, text);
}

enum ElemType {
  heading('h[1-6]'),
  rule('hr'),
  paragraph('p'),
  preformatted('pre'),
  blockQuote('blockquote', blockInside: true),
  orderList('ol', blockInside: true),
  unOrderList('ul', blockInside: true),
  listLine('li', blockInside: true),
  bold('strong', inline: true),
  italic('em', inline: true),
  code('code', inline: true),
  image('img', inline: true),
  link('a', inline: true),
  text('', inline: true);

  final String tag;
  final bool blockInside; // can contain blocks
  final bool inline; // can not contain ?line break?

  static final _headingPattern = RegExp(ElemType.heading.tag);

  const ElemType(this.tag, {this.blockInside = false, this.inline = false});

  static ElemType of(String tag) {
    if (_headingPattern.hasMatch(tag)) return ElemType.heading;
    return ElemType.values.firstWhere((element) => element.tag == tag, orElse: () => ElemType.text);
  }
}
