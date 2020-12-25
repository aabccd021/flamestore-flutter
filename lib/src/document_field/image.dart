part of '../../flamestore.dart';

class ImageField extends DocumentField {
  final File file;
  final int height;
  final int width;
  final int fileSize;
  final String userId;
  final String url;

  ImageField(
    this.url, {
    @required this.file,
    @required this.userId,
    this.fileSize,
    this.height,
    this.width,
  });

  @override
  Map<String, dynamic> get value {
    return {
      'url': url,
      'height': height,
      'width': width,
      'fileSize': fileSize,
    };
  }

  Map<String, dynamic> get firestoreValue => {'url': url};

  @override
  bool operator ==(other) => other is ImageField && other.url == url;
}
