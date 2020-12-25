part of '../../flamestore.dart';

class ImagePickerController {
  Future Function() pickImage;

  void dispose() {
    pickImage = null;
  }
}

class _ImageSnapshot {
  _ImageSnapshot(this.file, this.bytes);
  final File file;
  final Uint8List bytes;
  bool get hasImageFile => file != null;
}

class ImagePickerBuilder extends StatefulWidget {
  ImagePickerBuilder({
    this.controller,
    @required this.builder,
    this.source = ImageSource.gallery,
    ImagePickerBuilder picker,
    Key key,
  })  : picker = picker ?? ImagePicker(),
        super(key: key);
  final ImagePickerController controller;
  final ImageSource source;
  final Widget Function(_ImageSnapshot snapshot) builder;
  final ImagePicker picker;

  @override
  _ImagePickerBuilderState createState() => _ImagePickerBuilderState();
}

class _ImagePickerBuilderState extends State<ImagePickerBuilder> {
  _ImageSnapshot imageFile;
  @override
  void initState() {
    imageFile = _ImageSnapshot(null, null);
    widget.controller.pickImage = pickImage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(imageFile);
  }

  Future<void> pickImage() async {
    final pickedFile = await widget.picker.getImage(source: widget.source);
    final file = File(pickedFile.path);
    final bytes = await pickedFile.readAsBytes();
    if (pickedFile != null) {
      setState(() => this.imageFile = _ImageSnapshot(file, bytes));
    }
  }
}
