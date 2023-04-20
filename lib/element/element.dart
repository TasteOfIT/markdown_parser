part 'group_element.dart';

part 'link_element.dart';

part 'text_element.dart';

abstract class MarkdownElement {
  final ElementType type;
  final String text;

  MarkdownElement(this.type, this.text);
}

enum ElementType {
  paragraph('p', isParent: true),
  blockQuote('blockquote', isParent: true, inline: false),
  preformatted('pre', isParent: true, inline: false),
  orderList('ol', isParent: true, inline: false),
  unOrderList('ul', isParent: true, inline: false),
  listLine('li', isParent: true, inline: false),
  heading('h[1-6]', isParent: false, inline: false),
  bold('strong'),
  italic('em'),
  code('code'),
  image('img'),
  link('a'),
  plain('');

  final String tag;
  final bool isParent; // need break down to smaller elements
  final bool inline; // need wrap on display

  static final _headingPattern = RegExp(ElementType.heading.tag);

  const ElementType(this.tag, {this.isParent = false, this.inline = true});

  static ElementType of(String tag) {
    if (_headingPattern.hasMatch(tag)) return ElementType.heading;
    return ElementType.values.firstWhere((element) => element.tag == tag, orElse: () => ElementType.plain);
  }
}
