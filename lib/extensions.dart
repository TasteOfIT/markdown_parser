import 'package:markdown/markdown.dart';

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
