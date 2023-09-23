import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moinak05_web_dev_dashboard/provider/photography.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:path/path.dart';

class PhotographyUploader extends ConsumerStatefulWidget {
  const PhotographyUploader({super.key});

  @override
  ConsumerState<PhotographyUploader> createState() =>
      _PhotographyUploaderState();
}

class _PhotographyUploaderState extends ConsumerState<PhotographyUploader> {
  late void Function(String val) _smackMsg;
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

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    _smackMsg = (String smack) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          content: Text(
            smack,
            style: textTheme.titleMedium!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    };

    return AlertDialog(
      title: Text(
        _selectedImage == null
            ? 'Upload photography'
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
        if ((!_isLoading && !_isSuccess) || _selectedImage == null)
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

  void handelUpload() async {
    if (_selectedImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    final imgName = basename(_selectedImage!.path);

    final storageRef =
        FirebaseStorage.instance.ref().child('photography').child(imgName);
    await storageRef.putFile(_selectedImage!);

    final storageUrl = await storageRef.getDownloadURL();

    final url = Uri.https(dotenv.env['SERVER']!, 'addPhotography');
    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "url": storageUrl,
      "name": imgName,
    };

    final response = await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      ref.read(photographyProvider.notifier).fetch();
      await ref.read(storageProvider.notifier).explicitlyAddItem(
            imgName: imgName,
            dir: 'photography',
            image: _selectedImage!,
            url: storageUrl,
          );
      _smackMsg(
          '$imgName is uploaded successfully, Upload a new image or close.');
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _selectedImage = null;
      });
    } else {
      _smackMsg('Failed to delete $imgName');
      setState(() {
        _isLoading = false;
        _isLoading = false;
        _selectedImage = null;
      });
      throw Exception('Api Failed...');
    }
  }
}
