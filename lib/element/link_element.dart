part of 'element.dart';

abstract class Link extends MarkdownElement {
  String address;

  Link(this.address, super.type);
}

class ImageLink extends Link {
  String alt;

  ImageLink(String address, this.alt) : super(address, ElementType.image);
}

class UrlLink extends Link {
  String text;

  UrlLink(String address, this.text) : super(address, ElementType.link);
}
