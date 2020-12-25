part of '../../flamestore.dart';

class DynamicLinkField extends DocumentField {
  final String url;
  String title;
  String description;
  String imageUrl;
  bool isSuffixShort;

  DynamicLinkField(
    this.url, {
    this.title,
    this.description,
    this.imageUrl,
    this.isSuffixShort,
  });

  DynamicLinkField.fromMap(this.url);

  @override
  String get value => url;
}
