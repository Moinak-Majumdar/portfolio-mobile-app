import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moinak05_web_dev_dashboard/provider/profile_img.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChangeProfile extends ConsumerStatefulWidget {
  const ChangeProfile({super.key});

  @override
  ConsumerState<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends ConsumerState<ChangeProfile> {
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSuccess = false;

  void _pickPicture() async {
    final ip = ImagePicker();
    XFile? pikedImage;

    pikedImage = await ip.pickImage(
      source: ImageSource.gallery,
    );

    if (pikedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pikedImage!.path);
    });
  }

  void handelUpload() async {
    if (_selectedImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    final imgName = basename(_selectedImage!.path);

    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/userData');
    String workDirPath;

    if (await workDir.exists()) {
      workDir.deleteSync(recursive: true);
    }
    final newFolder = await workDir.create(recursive: true);
    workDirPath = newFolder.path;

    final copy = await _selectedImage!.copy('$workDirPath/$imgName');

    await ref.read(profileImgProvider.notifier).addProfileImg(
        imgName: 'default',
        dir: 'profile',
        localPath: copy.path,
        url: 'not needed');
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        _selectedImage == null
            ? 'Upload Display Image'
            : basename(_selectedImage!.path),
        style: textTheme.titleLarge,
      ),
      content: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 16),
        height: 200,
        width: 300,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.secondary,
              colorScheme.onSurface,
            ],
          ),
        ),
        child: _selectedImage == null
            ? Center(
                child: TextButton.icon(
                  onPressed: _pickPicture,
                  icon: const Icon(
                    Icons.upload_file,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'Choose picture',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            : Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: 300,
                    height: 200,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withAlpha(230),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _pickPicture,
                            icon: Icon(
                              Icons.upload_file,
                              color: colorScheme.inversePrimary,
                            ),
                            label: const Text(
                              'choose again',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        if (_isLoading) const CircularProgressIndicator(),
        if (!_isLoading && !_isSuccess)
          OutlinedButton.icon(
            onPressed: handelUpload,
            icon: const Icon(Icons.upload),
            label: Text(
              'upload',
              style: TextStyle(color: colorScheme.primaryContainer),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(colorScheme.primary),
              iconColor: MaterialStatePropertyAll(colorScheme.primaryContainer),
              side: const MaterialStatePropertyAll(BorderSide.none),
            ),
          ),
        if (_isSuccess)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cancel),
            label: Text(
              'close',
              style: TextStyle(color: colorScheme.errorContainer),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(colorScheme.error),
              iconColor: MaterialStatePropertyAll(colorScheme.errorContainer),
              side: const MaterialStatePropertyAll(BorderSide.none),
            ),
          ),
      ],
    );
  }
}
