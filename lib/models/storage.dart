import 'dart:io';

class StorageSchema {
  StorageSchema({
    required this.dir,
    required this.image,
    required this.imgName,
    this.url = '',
  });

  final String imgName, dir, url;
  final File image;
}
