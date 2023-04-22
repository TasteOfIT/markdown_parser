part of 'element.dart';

class ImageLink extends Inline {
  final String src;
  final String? alt;
  final String? title;

  ImageLink(this.src, {this.alt, this.title}) : super(ElemType.image, text: alt ?? title ?? '');

  static ImageLink from(Element element) {
    String src = element.attributes['src'] ?? '';
    String? alt = element.attributes['alt'];
    String? title = element.attributes['title'];
    return ImageLink(src, alt: alt, title: title);
  }
}

class UrlLink extends Inline {
  final String link;
  final String? label;
  final String? title;

  UrlLink(this.link, {this.label, this.title}) : super(ElemType.link, text: label ?? title ?? '');

  static UrlLink from(Element element) {
    String link = element.attributes['href'] ?? '';
    String? label = element.children?.first.textContent;
    String? title = element.attributes['title'];
    return UrlLink(link, label: label, title: title);
  }
}
