import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/smack_msg.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:moinak05_web_dev_dashboard/provider/cloud.dart';

class ImageUploader extends ConsumerStatefulWidget {
  const ImageUploader({
    super.key,
  });

  @override
  ConsumerState<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends ConsumerState<ImageUploader> {
  late void Function(String val) _smackMsg;
  File? _selectedImage;
  static final _formKey = GlobalKey<FormState>();
  String _enteredProjectName = '';
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    _smackMsg = (val) => SmackMsg(smack: val, context: context);

    return AlertDialog(
      title: Text(
        _selectedImage != null
            ? basename(_selectedImage!.path)
            : 'Upload Image',
        style: textTheme.titleLarge,
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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              enableSuggestions: true,
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text('Project / Work name'),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Required *';
                }
                if (val.trim().length < 4) {
                  return 'Name at least 4 characters long';
                }
                return null;
              },
              onSaved: (val) {
                _enteredProjectName = val!;
              },
            ),
            Container(
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
          ],
        ),
      ),
    );
  }

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
    final valid = _formKey.currentState!.validate();
    if (!valid && _selectedImage == null) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    final imgName = basename(_selectedImage!.path);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(_enteredProjectName)
        .child(imgName);

    await storageRef.putFile(_selectedImage!);

    final storageUrl = await storageRef.getDownloadURL();

    final url = Uri.https(dotenv.env['SERVER']!, 'addCloudImg');
    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "projectName": _enteredProjectName,
      "imgName": imgName,
      "url": storageUrl,
    };

    final response = await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      ref.read(cloudProvider.notifier).fetch();
      await ref.read(storageProvider.notifier).explicitlyAddItem(
            dir: _enteredProjectName,
            imgName: imgName,
            image: _selectedImage!,
            url: storageUrl,
          );
      _smackMsg(
          '$imgName is uploaded successfully. Upload a new image or close.');
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _selectedImage = null;
      });
    } else {
      _formKey.currentState!.reset();
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
