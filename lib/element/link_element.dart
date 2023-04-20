part of 'element.dart';

abstract class Link extends MarkdownElement {
  String address;

  Link(this.address, super.type, super.text);
}

class ImageLink extends Link {
  final String alt;

  ImageLink(String address, this.alt) : super(address, ElementType.image, alt);
}

class UrlLink extends Link {
  final String name;

  UrlLink(String address, this.name) : super(address, ElementType.link, name);
}
