import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/submit_button.dart';

class FbPhotographyUploader extends StatefulWidget {
  const FbPhotographyUploader({super.key});

  @override
  State<FbPhotographyUploader> createState() => _FbPhotographyUploaderState();
}

class _FbPhotographyUploaderState extends State<FbPhotographyUploader> {
  File? _selectedPhotography;
  bool _isLoading = false;

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
      _selectedPhotography = File(pikedImage!.path);
    });
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          Text(
            _selectedPhotography == null
                ? 'Upload Photography'
                : basename(_selectedPhotography!.path),
            style: textTheme.titleLarge,
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            height: 300,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black38, Colors.black26, Colors.black38],
              ),
            ),
            child: _selectedPhotography == null
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
                        _selectedPhotography!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withAlpha(170),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: _isLoading ? null : _pickPicture,
                                icon: const Icon(Icons.upload_file),
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
          SubmitButton(
            onTap: _selectedPhotography != null ? handelUpload : () {},
            loading: _isLoading,
            title: "Upload",
            onLoadText: "Uploading ...",
            showDisable: _selectedPhotography == null,
            leadingIcon: Icons.upload,
            borderRadius: BorderRadius.circular(12),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          )
        ],
      ),
    );
  }

  void handelUpload() async {
    if (_selectedPhotography == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final imgName = basename(_selectedPhotography!.path);

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('photography').child(imgName);
      await storageRef.putFile(_selectedPhotography!);
    } catch (e) {
      GetSnack.error(message: e.toString());
    }

    GetSnack.success(
      message: '$imgName is uploaded to Firebase.',
    );

    setState(() {
      _isLoading = false;
      _selectedPhotography = null;
    });
  }
}
